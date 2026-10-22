"use client";

import Link, { useLinkStatus } from "next/link";
import type { Route } from "next";
import type { CSSProperties, ReactNode } from "react";

/**
 * Un onglet d'étage qui réagit À L'INSTANT où on l'appuie.
 *
 * Changer d'étage redemande la liste au serveur : entre l'appui et la
 * réponse, l'onglet ne bougeait pas, et on réappuyait en croyant que rien
 * ne s'était passé. Dès l'appui, sans délai, l'onglet se cerne et
 * son voile pulse jusqu'à l'arrivée de la liste.
 */
export function OngletEtage({
  href,
  actif,
  className,
  style,
  children,
}: {
  href: string;
  actif?: boolean;
  className: string;
  style?: CSSProperties;
  children: ReactNode;
}) {
  return (
    <Link
      replace
      href={href as Route}
      aria-current={actif ? "page" : undefined}
      className={`relative ${className}`}
      style={style}
    >
      <EnAttente />
      {children}
    </Link>
  );
}

function EnAttente() {
  const { pending } = useLinkStatus();
  if (!pending) return null;
  return (
    // Un cadre et un voile qui pulse : rien par-dessus le nom ni le compte,
    // qu'on doit pouvoir continuer à lire.
    <span
      aria-hidden
      className="absolute inset-0 rounded-r-[10px] ring-[3px] ring-inset ring-ink bg-ink/20 animate-pulse"
    />
  );
}
