#!/usr/bin/env python3
"""Signe les fichiers d'installation et produit le diagnostic « où en suis-je ».

Neuf fichiers à coller dans un éditeur de navigateur, c'est neuf occasions de
se tromper de fichier ou de croire qu'un collage a pris. Chaque fichier se
termine donc par deux choses : il inscrit son nom dans `installation_journal`,
et il affiche ce nom en résultat. On ne devine plus ce qui a tourné, on le lit.
"""
from pathlib import Path

DOSSIER = Path(__file__).resolve().parent.parent / "donnees" / "installation"

# Ce que chaque fichier affiche une fois passé. La table comptée est celle
# qu'il remplit : un fichier qui n'aurait rien fait se verrait au chiffre.
CONSTATS = {
    "1-schema-et-referentiels.sql":
        "(select count(*) || ' emplacements — le schéma est en place' from emplacements)",
    "3-stock.sql":
        "(select count(*) || ' produits sur 36' from produits)",
    "4-bouteilles.sql":
        "(select count(*) || ' dossiers de bouteille sur 17' from incidents_bouteille)",
    "6-passages.sql":
        "(select count(*) || ' passages reconstitués' from tournees where reprise)",
    "5-equipe.sql":
        "(select case when exists (select 1 from prestataires where nom = 'ALAIN')"
        " then 'noms NON corrigés' else 'noms corrigés — installation terminée' end)",
}
CONSTAT_ANOMALIES = "(select count(*) || ' anomalies sur 674' from anomalies)"


def ordre(nom: str):
    """Trie 1, 2-a, 2-b, … 5 comme on les joue."""
    return (nom[0], nom)


def fichiers() -> list[str]:
    """Les fichiers à coller : les morceaux, jamais l'entier dont ils sortent."""
    tous = {f.name for f in DOSSIER.glob("*.sql") if not f.name.startswith("0-")}
    decoupes = {n.rsplit("-", 1)[0] + ".sql" for n in tous if n[-6] == "-"}
    return sorted(tous - decoupes, key=ordre)


def constat_de(nom: str) -> str:
    """Le constat du fichier, ou celui de l'entier dont il est un morceau."""
    entier = nom.rsplit("-", 1)[0] + ".sql" if nom[-6] == "-" else nom
    return CONSTATS.get(nom) or CONSTATS.get(entier) or CONSTAT_ANOMALIES


def signer(nom: str) -> None:
    constat = constat_de(nom)
    # La table du journal se crée ici et pas seulement dans le fichier 1 :
    # une base installée avant son existence la gagne au premier fichier joué.
    (DOSSIER / nom).open("a", encoding="utf-8").write(f"""

-- Trace de passage : c'est elle que lit 0-ou-en-suis-je.sql.
create table if not exists installation_journal (
  fichier  text primary key,
  joue_le  timestamptz not null default now()
);
insert into installation_journal (fichier) values ('{nom}')
  on conflict (fichier) do update set joue_le = now();

select '{nom}' as "Fichier joué", {constat} as "Où ça en est";
""")


def diagnostic(noms: list[str]) -> None:
    attendus = ",\n      ".join(f"({i + 1}, '{n}')" for i, n in enumerate(noms))
    (DOSSIER / "0-ou-en-suis-je.sql").write_text(f"""\
-- -----------------------------------------------------------------------------
-- Où en suis-je ? — à jouer quand on ne sait plus quel fichier a été passé.
-- -----------------------------------------------------------------------------
-- Ne modifie rien. Se rejoue à volonté. Produit par
-- outils/finaliser_installation.py : la liste suit les fichiers réellement
-- livrés, elle ne se recopie pas à la main.
do $$
begin
  if to_regclass('public.installation_journal') is null then
    create temp table if not exists installation_journal (
      fichier text primary key, joue_le timestamptz
    );
    delete from installation_journal;
  end if;
end $$;

with attendus (rang, fichier) as (
  values
      {attendus}
),
faits as (
  select fichier from installation_journal
  union
  -- Une base commencée avant l'existence du journal : le schéma prouve à lui
  -- seul que le fichier 1 est passé, et il refuserait d'être rejoué.
  select '1-schema-et-referentiels.sql'
   where to_regclass('public.emplacements') is not null
),
etat as (
  select a.rang, a.fichier, (f.fichier is not null) as joue,
         min(a.rang) filter (where f.fichier is null) over () as prochain
    from attendus a left join faits f on f.fichier = a.fichier
)
select fichier as "Fichier",
       case when joue              then 'joué'
            when rang = prochain   then '>>> À JOUER MAINTENANT <<<'
            else                        'à venir'
       end as "État"
  from etat
 order by rang;
""", encoding="utf-8")


def manifeste(noms: list[str]) -> None:
    """L'ordre de jeu, lisible par un script — une seule source de vérité."""
    (DOSSIER / "ordre.txt").write_text(
        "# Les fichiers d'installation, dans l'ordre. Produit par\n"
        "# outils/finaliser_installation.py — ne pas éditer à la main.\n"
        + "\n".join(noms) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    noms = fichiers()
    for n in noms:
        signer(n)
    diagnostic(noms)
    manifeste(noms)
    print(f"{len(noms)} fichiers signés, diagnostic et ordre produits")
