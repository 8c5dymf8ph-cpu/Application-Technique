// Aperçu temporaire — à retirer une fois un parti retenu pour l'accueil.

function IconGouvernante() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#453A6E" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="8.4" />
      <path d="M8.4 12.3l2.3 2.3 4.7-5.1" />
    </svg>
  );
}
function IconTechnique() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#357051" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
      <path d="M14.7 6.3a1 1 0 000 1.4l1.6 1.6a1 1 0 001.4 0l3.77-3.77a6 6 0 01-7.94 7.94l-6.91 6.91a2.12 2.12 0 01-3-3l6.91-6.91a6 6 0 017.94-7.94z" />
    </svg>
  );
}
function IconBouteilles() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#3A6499" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3s6 6.5 6 11a6 6 0 01-12 0c0-4.5 6-11 6-11z" />
    </svg>
  );
}
function IconStock() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#A8641F" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3.5 8.5L12 4l8.5 4.5L12 13z" />
      <path d="M3.5 8.5V16L12 20.5 20.5 16V8.5" />
      <path d="M12 13v7.5" />
    </svg>
  );
}
function IconAdmin() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#4F4B6B" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 7h9M17 7h3M4 17h3M11 17h9" />
      <circle cx="15" cy="7" r="2.3" />
      <circle cx="8" cy="17" r="2.3" />
    </svg>
  );
}

function Compteur({ valeur, libelle, ton, bord }: { valeur: number; libelle: string; ton: string; bord: string }) {
  return (
    <div className={`flex-1 rounded-[16px] bg-surface border-b-[3px] ${bord} px-2 py-5 flex flex-col items-center gap-1 shadow-[0_6px_14px_-6px_rgba(27,25,48,0.16)]`}>
      <span className={`font-display font-semibold text-[30px] leading-none tabular-nums ${ton}`}>{valeur}</span>
      <span className="etiquette">{libelle}</span>
    </div>
  );
}

/**
 * Un bord inférieur plein, dans la teinte forte de la carte, simule
 * l'épaisseur d'une touche : on VOIT la tranche, pas seulement une ombre.
 */
function Tuile({
  icone,
  fond,
  bord,
  titre,
  detail,
  badge,
}: {
  icone: React.ReactNode;
  fond: string;
  bord: string;
  titre: string;
  detail: string;
  badge: number;
}) {
  return (
    <a
      href="#"
      className={`${fond} border-b-[5px] ${bord} rounded-[20px] px-5 py-[18px] flex items-center gap-4 min-h-[96px] shadow-[0_10px_18px_-9px_rgba(27,25,48,0.30)]`}
    >
      <span className="shrink-0 w-11 h-11 rounded-[13px] bg-white/70 grid place-items-center">{icone}</span>
      <div className="flex flex-col gap-[3px] grow min-w-0">
        <span className="font-display font-bold text-[21px] text-ink">{titre}</span>
        <span className="text-[13px] text-ink-soft">{detail}</span>
      </div>
      <span className="shrink-0 min-w-[34px] h-[34px] px-2 rounded-[10px] bg-white grid place-items-center font-display font-semibold text-[16px] text-ink tabular-nums">
        {badge}
      </span>
    </a>
  );
}

export default function ApercuB() {
  return (
    <main className="min-h-dvh px-5 pb-8 pt-8 flex flex-col gap-7 max-w-md mx-auto bg-ground">
      <div className="flex flex-col gap-[2px]">
        <div className="flex items-center gap-3">
          <p className="text-[14px] text-ink-faint grow min-w-0 truncate">Bonjour Miguel</p>
          <span className="shrink-0 flex items-center gap-2 h-11 pl-1.5 pr-3 rounded-full bg-surface border-b-[3px] border-b-line shadow-[0_4px_10px_-4px_rgba(27,25,48,0.16)]">
            <span className="w-8 h-8 rounded-full bg-plum grid place-items-center font-display font-semibold text-[12.5px] text-white">
              MI
            </span>
            <span className="text-[12.5px] text-ink-soft">Changer</span>
          </span>
        </div>
        <h1 className="font-display font-bold text-[32px] leading-tight tracking-tight">Hôtel Parisianer</h1>
        <p className="text-[13px] text-ink-faint mt-1">Vendredi 26 septembre</p>
      </div>

      <div className="grid grid-cols-3 gap-2.5">
        <Compteur valeur={6} libelle="À faire" ton="text-amber" bord="border-b-amber" />
        <Compteur valeur={3} libelle="En cours" ton="text-blue" bord="border-b-blue" />
        <Compteur valeur={4} libelle="À valider" ton="text-plum" bord="border-b-plum" />
      </div>

      <nav className="flex flex-col gap-3.5">
        <Tuile
          icone={<IconGouvernante />}
          fond="bg-plum-soft"
          bord="border-b-plum"
          titre="Gouvernante"
          detail="Déclarer, valider, suivre"
          badge={4}
        />
        <Tuile
          icone={<IconTechnique />}
          fond="bg-green-soft"
          bord="border-b-green"
          titre="Technique"
          detail="Ma tournée du jour"
          badge={6}
        />
        <Tuile
          icone={<IconBouteilles />}
          fond="bg-blue-soft"
          bord="border-b-blue"
          titre="Bouteilles"
          detail="Parc Purezza et dossiers"
          badge={2}
        />
        <Tuile
          icone={<IconStock />}
          fond="bg-amber-soft"
          bord="border-b-amber"
          titre="Stock"
          detail="Produits, seuils, inventaire"
          badge={3}
        />
        <Tuile
          icone={<IconAdmin />}
          fond="bg-surface-muted"
          bord="border-b-line"
          titre="Administration"
          detail="Factures, référentiels, envois"
          badge={5}
        />
      </nav>
    </main>
  );
}
