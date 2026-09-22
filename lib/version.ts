/**
 * Quelle version de l'application est en ligne.
 *
 * « Les modifications ne sont pas là » et « le code est poussé » peuvent être
 * vrais en même temps : entre les deux il y a un déploiement, qui peut ne pas
 * avoir eu lieu, avoir échoué, ou avoir été servi depuis le cache du
 * téléphone. Sans repère, la seule façon d'en sortir est de comparer des
 * écrans de mémoire — et on se trompe.
 *
 * Vercel pose le commit déployé dans l'environnement. On l'affiche donc en
 * clair dans `/administration` : le titre du commit se lit en français, et se
 * compare en une seconde avec ce qui est annoncé.
 *
 * Si les variables système de Vercel sont désactivées dans le projet, on le
 * dit plutôt que d'inventer — une version fausse est pire que pas de version.
 */
export type Version = {
  /** Les sept premiers caractères du commit, comme GitHub les affiche. */
  court: string | null;
  /** La première ligne du message de commit : c'est elle qui parle. */
  titre: string | null;
  /** La branche déployée. */
  branche: string | null;
  /** Vrai quand l'application tourne sur un poste, pas en ligne. */
  locale: boolean;
};

export function version(): Version {
  const sha = process.env.VERCEL_GIT_COMMIT_SHA ?? null;
  const message = process.env.VERCEL_GIT_COMMIT_MESSAGE ?? null;
  return {
    court: sha ? sha.slice(0, 7) : null,
    titre: message ? (message.split("\n")[0] ?? null) : null,
    branche: process.env.VERCEL_GIT_COMMIT_REF ?? null,
    locale: !process.env.VERCEL,
  };
}
