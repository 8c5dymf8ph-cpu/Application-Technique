import { createHmac, randomBytes, scryptSync, timingSafeEqual } from "node:crypto";
import { sql } from "./db";

/**
 * Le code de l'hôtel : ce qui ferme la porte AVANT le choix du profil.
 *
 * L'application était ouverte à quiconque connaissait son adresse. Un seul code,
 * partagé par l'équipe, demandé une fois par appareil puis retenu trente jours.
 * `proxy.ts` le vérifie devant CHAQUE requête — écrans, photos, exports,
 * actions — et `/acces` le demande. Tant qu'aucun code n'est posé (ou que la
 * migration 0042 n'est pas jouée), l'application reste ouverte, comme avant :
 * poser la serrure ne doit enfermer personne dehors. `/administration` le dit
 * en rouge.
 *
 * Ce qui est posé sur l'appareil n'est pas le code : c'est un jeton signé
 * (version du code, date d'expiration, signature HMAC avec un secret qui ne
 * quitte jamais le serveur). Changer le code change la version, et tous les
 * jetons tombent : c'est le geste quand quelqu'un quitte l'hôtel.
 */

export const COOKIE_ACCES = "acces";
export const DUREE_ACCES_JOURS = 30;
/** Un code devinable en quelques centaines d'essais ne protège rien. */
export const LONGUEUR_MINIMALE = 6;
/** Au-delà, l'appareil attend : on n'essaie pas tous les codes un par un. */
export const ESSAIS_PERMIS = 8;
export const FENETRE_MINUTES = 15;

export type EtatAcces = {
  /** La migration 0042 est jouée. */
  pret: boolean;
  /** Un code est posé : la porte est fermée. */
  actif: boolean;
  version: number;
  secret: string | null;
  changeLe: Date | null;
};

const OUVERT: EtatAcces = { pret: false, actif: false, version: 0, secret: null, changeLe: null };

// Le proxy passe devant chaque requête : relire la base à chaque fois coûterait
// un aller-retour par écran, par photo. Il tourne dans une mémoire à part de
// celle des écrans — `oublierEtat()` appelé depuis l'administration ne le
// touche pas —, donc un nouveau code met jusqu'à ce délai à fermer la porte.
// Dix secondes : assez pour épargner la base, trop peu pour qu'on le remarque.
let memoire: { etat: EtatAcces; lu: number } | null = null;
const MEMOIRE_MS = 10_000;

export function oublierEtat() {
  memoire = null;
}

export async function etatAcces(): Promise<EtatAcces> {
  if (memoire && Date.now() - memoire.lu < MEMOIRE_MS) return memoire.etat;
  let etat: EtatAcces;
  try {
    const [l] = await sql<
      { code_empreinte: string | null; secret: string | null; version: number; change_le: Date | null }[]
    >`select code_empreinte, secret, version, change_le from acces_hotel where id`;
    etat = l
      ? {
          pret: true,
          actif: Boolean(l.code_empreinte && l.secret),
          version: l.version,
          secret: l.secret,
          changeLe: l.change_le,
        }
      : { ...OUVERT, pret: true };
  } catch (e) {
    // La table n'existe pas encore : la migration n'est pas jouée, la porte
    // reste ouverte comme avant. Toute autre erreur remonte — le proxy ferme.
    if ((e as { code?: string }).code === "42P01") etat = OUVERT;
    else throw e;
  }
  memoire = { etat, lu: Date.now() };
  return etat;
}

function signature(secret: string, charge: string) {
  return createHmac("sha256", secret).update(charge).digest("base64url");
}

/** Le jeton posé sur l'appareil qui vient de donner le bon code. */
export function jeton(etat: EtatAcces): { valeur: string; expire: Date } {
  const expire = new Date(Date.now() + DUREE_ACCES_JOURS * 86_400_000);
  const charge = `${etat.version}.${expire.getTime()}`;
  return { valeur: `${charge}.${signature(etat.secret ?? "", charge)}`, expire };
}

export function jetonValide(valeur: string | undefined, etat: EtatAcces): boolean {
  if (!valeur || !etat.secret) return false;
  const [version, expire, sig] = valeur.split(".");
  if (!version || !expire || !sig) return false;
  if (Number(version) !== etat.version || Number(expire) < Date.now()) return false;
  const attendue = Buffer.from(signature(etat.secret, `${version}.${expire}`));
  const recue = Buffer.from(sig);
  return attendue.length === recue.length && timingSafeEqual(attendue, recue);
}

function empreinte(code: string, sel = randomBytes(16).toString("hex")) {
  return `scrypt$${sel}$${scryptSync(code, sel, 32).toString("hex")}`;
}

export async function codeJuste(code: string): Promise<boolean> {
  const [l] = await sql<{ code_empreinte: string | null }[]>`
    select code_empreinte from acces_hotel where id`;
  const [, sel, attendu] = (l?.code_empreinte ?? "").split("$");
  if (!sel || !attendu) return false;
  const recu = Buffer.from(empreinte(code.trim(), sel).split("$")[2], "hex");
  const ref = Buffer.from(attendu, "hex");
  return recu.length === ref.length && timingSafeEqual(recu, ref);
}

/**
 * Poser un nouveau code. La version monte : tous les appareils déjà entrés
 * devront le redonner. Le secret est tiré la première fois, puis renouvelé à
 * chaque changement — un jeton volé avant ne vaut plus rien après.
 */
export async function poserCode(code: string, par: string | null) {
  await sql`
    update acces_hotel
       set code_empreinte = ${empreinte(code.trim())},
           secret = ${randomBytes(32).toString("hex")},
           version = version + 1,
           change_le = now(),
           change_par = ${par}
     where id`;
  oublierEtat();
}

/** L'adresse d'où vient la requête, telle que Vercel la transmet. */
export function adresseDe(entetes: Headers): string {
  return (
    entetes.get("x-forwarded-for")?.split(",")[0]?.trim() ||
    entetes.get("x-real-ip") ||
    "inconnue"
  );
}

/**
 * Combien d'échecs récents pour cette adresse, et quand on pourra réessayer.
 * Un succès remet le compte à zéro : une collègue qui se trompe deux fois ne
 * pèse pas sur la suivante.
 */
export async function attente(ip: string): Promise<{ bloque: boolean; minutes: number }> {
  const [l] = await sql<{ n: number; premier: Date | null }[]>`
    select count(*)::int as n, min(le) as premier
      from acces_essais
     where ip = ${ip} and not reussi
       and le > now() - make_interval(mins => ${FENETRE_MINUTES})
       and le > coalesce((select max(le) from acces_essais where ip = ${ip} and reussi),
                         '-infinity'::timestamptz)`;
  if (!l || l.n < ESSAIS_PERMIS || !l.premier) return { bloque: false, minutes: 0 };
  const fin = new Date(l.premier).getTime() + FENETRE_MINUTES * 60_000;
  return { bloque: true, minutes: Math.max(1, Math.ceil((fin - Date.now()) / 60_000)) };
}

export async function noterEssai(ip: string, reussi: boolean) {
  await sql`insert into acces_essais (ip, reussi) values (${ip}, ${reussi})`;
  // Ce qui a plus d'un jour ne sert plus au calcul.
  await sql`delete from acces_essais where le < now() - interval '1 day'`;
}
