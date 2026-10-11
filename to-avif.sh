#!/usr/bin/env bash
# to-avif.sh — convierte a AVIF las covers/screenshots VERSIONADAS del repo de
# metadatos (deja los .gif intactos). Copia los originales a un backup antes de
# borrarlos.
#
# Uso:
#   nix shell nixpkgs#libavif -c bash to-avif.sh [-q 75] [-j N] [-n] [-b DIR]
#
# Opciones:
#   -q, --quality N   Calidad AVIF 0-100 (def. 75).
#   -j, --jobs N      Procesos en paralelo (def. nproc).
#   -n, --dry-run     Solo lista lo que haría.
#   -b, --backup DIR  Directorio de backup (def. ~/Descargas/samt-metadata-images-backup-<fecha>).
#       --no-backup   No hace backup (borra los originales).
#       --encoder X   avifenc (def.) o magick.
#   -h, --help        Muestra esta ayuda.
set -euo pipefail

QUALITY=75
JOBS="$(nproc 2>/dev/null || echo 4)"
DRY=0
BACKUP="$HOME/Descargas/samt-metadata-images-backup-$(date +%F)"
ENCODER=avifenc

while [ $# -gt 0 ]; do
  case "$1" in
    -q|--quality) QUALITY="$2"; shift 2;;
    -j|--jobs)    JOBS="$2"; shift 2;;
    -n|--dry-run) DRY=1; shift;;
    -b|--backup)  BACKUP="$2"; shift 2;;
    --no-backup)  BACKUP=""; shift;;
    --encoder)    ENCODER="$2"; shift 2;;
    -h|--help)    grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) echo "opción desconocida: $1" >&2; exit 2;;
  esac
done

cd "$(git rev-parse --show-toplevel)"

case "$ENCODER" in
  avifenc) command -v avifenc >/dev/null || { echo "falta 'avifenc' (usa: nix shell nixpkgs#libavif)"; exit 1; };;
  magick)  command -v magick  >/dev/null || { echo "falta 'magick'"; exit 1; };;
  *) echo "encoder no soportado: $ENCODER (usa avifenc o magick)"; exit 2;;
esac

# Solo ficheros versionados (ignora content/, extras/, …).
mapfile -d '' FILES < <(git ls-files -z -- \
  ':(glob)**/cover.jpg' ':(glob)**/cover.png' ':(glob)**/cover.webp' \
  ':(glob)**/screenshots/**/*.jpg' ':(glob)**/screenshots/**/*.png' ':(glob)**/screenshots/**/*.webp')

echo "candidatos: ${#FILES[@]}  encoder=$ENCODER q=$QUALITY jobs=$JOBS dry=$DRY"
[ -n "$BACKUP" ] && echo "backup: $BACKUP"

if [ "$DRY" = 1 ]; then
  for f in "${FILES[@]}"; do echo "DRY  $f -> ${f%.*}.avif"; done
  exit 0
fi

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

encode() { # $1 = fichero versionado (ruta relativa al repo)
  local src="$1" dst="${1%.*}.avif" tmp input="$1"
  [ -e "$dst" ] && { echo "SKIP $src"; return 0; }
  tmp="$(mktemp "$TMP/XXXXXX.avif")"
  if [ "$ENCODER" = avifenc ]; then
    # avifenc no lee webp: se decodifica a PNG con magick primero.
    if [ "${src##*.}" = webp ]; then
      input="$(mktemp "$TMP/XXXXXX.png")"
      magick "$src" "$input" || { echo "FAIL $src"; rm -f "$tmp" "$input"; return 1; }
    fi
    avifenc -j 1 -q "$QUALITY" "$input" "$tmp" >/dev/null || { echo "FAIL $src"; rm -f "$tmp" "$input"; return 1; }
  else
    magick "$src" -quality "$QUALITY" "$tmp" || { echo "FAIL $src"; rm -f "$tmp"; return 1; }
  fi
  mv -f "$tmp" "$dst"
  if [ -n "$BACKUP" ]; then
    mkdir -p "$BACKUP/$(dirname "$src")"
    cp -p "$src" "$BACKUP/$src"
  fi
  rm -f -- "$src"
  echo "OK   $src -> $dst"
}
export -f encode
export QUALITY ENCODER BACKUP TMP

printf '%s\0' "${FILES[@]}" | xargs -0 -I{} -P "$JOBS" bash -c 'encode "$@"' _ {}

echo "=== resumen ==="
echo ".avif versionados: $(git ls-files '*.avif' | wc -l)"
[ -n "$BACKUP" ] && du -sh "$BACKUP" 2>/dev/null || true
