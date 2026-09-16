import { lirePhoto, typeMime } from "@/lib/stockage";

export async function GET(
  _requete: Request,
  { params }: { params: Promise<{ nom: string }> },
) {
  const { nom } = await params;
  const contenu = await lirePhoto(nom);
  if (!contenu) return new Response("Introuvable", { status: 404 });

  return new Response(new Uint8Array(contenu), {
    headers: {
      "Content-Type": typeMime(nom),
      // Le nom porte un identifiant unique : le contenu ne change jamais.
      "Cache-Control": "public, max-age=31536000, immutable",
    },
  });
}
