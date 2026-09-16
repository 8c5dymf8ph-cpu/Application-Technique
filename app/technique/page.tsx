import { Entete, Vide } from "@/app/composants/ui";

export default function EnChantier() {
  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Technique" retour="/" />
      <Vide>Cet écran arrive dans la prochaine étape.</Vide>
    </main>
  );
}
