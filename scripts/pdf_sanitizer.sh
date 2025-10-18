#!/usr/bin/env bash
set -euo pipefail

# index_pdf_fixer.sh
# One-shot fixer for filenames like "… .pdf" → "….pdf" (remove the space before .pdf)
# Also updates MANIFEST.parts.yaml paths and renames matching parts_ocr/*.txt if present.
#
# USAGE:
#   ./pdf_sanitizer.sh         # dry-run (prints planned changes)
#   ./pdf_sanitizer.sh --apply  # perform the renames + manifest update
#
# Notes:
# - Works on macOS (BSD userland). Avoids GNU-only flags.
# - Defaults assume your project layout under $ROOT; override via env vars if needed.
#
# ENV OVERRIDES (optional):
#   ROOT=/Users/nickwade/Repos/Broomhilda
#   PARTS="$ROOT/parts"
#   OCR="$ROOT/parts_ocr"
#   MANIFEST="$ROOT/MANIFEST.parts.yaml"

# -------- config & args --------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${ROOT:-$SCRIPT_DIR}"

PARTS="${PARTS:-"$ROOT/parts"}"
OCR="${OCR:-"$ROOT/parts_ocr"}"
MANIFEST="${MANIFEST:-"$ROOT/MANIFEST.parts.yaml"}"

APPLY=0
if [ "${1:-}" = "--apply" ]; then
  APPLY=1
elif [ "${1:-}" != "" ]; then
  echo "usage: $0 [--apply]" >&2
  exit 2
fi

# -------- sanity checks --------
if [ ! -d "$PARTS" ]; then
  echo "error: parts directory not found: $PARTS" >&2
  exit 1
fi

if [ ! -f "$MANIFEST" ]; then
  echo "error: manifest not found: $MANIFEST" >&2
  exit 1
fi

echo "Project root:   $ROOT"
echo "PDF root:       $PARTS"
echo "OCR root:       $OCR"
echo "Manifest:       $MANIFEST"
echo "Mode:           $([ $APPLY -eq 1 ] && echo APPLY || echo DRY-RUN)"
echo

# -------- helpers --------
# replace a trailing " .pdf" (any case) with ".pdf"
_fix_pdf_name() {
  # preserve all but drop the single space before extension; normalize extension to .pdf
  # shellcheck disable=SC2001
  echo "$(printf "%s" "$1" | sed -E 's/ \.(pdf|PDF)$/\.pdf/')"
}

# given a parts/..../File.pdf -> derive OCR txt path (if mirroring exists)
_derive_ocr_txt() {
  local pdf_rel="$1"         # relative to $PARTS
  local base="${pdf_rel%.*}" # strip extension
  echo "$OCR/$base.txt"
}

# -------- scan & rename --------
changes=0
declare -a to_fix
# find case-insensitively: names ending with " .pdf" (space then .pdf/.PDF)
# Note: the parentheses grouping requires escaping in POSIX sh - here bash is fine.
while IFS= read -r -d '' f; do
  rel="${f#"$PARTS/"}"
  new_rel="$(_fix_pdf_name "$rel")"
  if [ "$rel" != "$new_rel" ]; then
    to_fix+=("$rel")
  fi
done < <(find "$PARTS" -type f \( -iname "* .pdf" -o -iname "* .PDF" \) -print0 | sort -z)

if [ ${#to_fix[@]} -eq 0 ]; then
  echo "No problematic PDF filenames found. 👍"
else
  for rel in "${to_fix[@]}"; do
    old_path="$PARTS/$rel"
    new_rel="$(_fix_pdf_name "$rel")"
    new_path="$PARTS/$new_rel"

    echo "Found bad PDF:"
    echo "  OLD: $rel"
    echo "  NEW: $new_rel"

    if [ -e "$new_path" ] && [ "$old_path" != "$new_path" ]; then
      echo "  ⚠️  Skip: target already exists: $new_path" >&2
      echo
      continue
    fi

    if [ $APPLY -eq 1 ]; then
      mkdir -p "$(dirname "$new_path")"
      mv -v -- "$old_path" "$new_path"
    else
      echo "(dry-run) Would rename:"
      echo "  $old_path -> $new_path"
    fi
    echo
    changes=$((changes + 1))

    # Try to rename OCR mirror if present (e.g., parts_ocr/<same path>.txt)
    ocr_old="$(_derive_ocr_txt "$rel")"
    ocr_new="$(_derive_ocr_txt "$new_rel")"
    if [ -f "$ocr_old" ]; then
      if [ $APPLY -eq 1 ]; then
        mkdir -p "$(dirname "$ocr_new")"
        mv -v -- "$ocr_old" "$ocr_new"
      else
        echo "(dry-run) Would rename OCR:"
        echo "  $ocr_old -> $ocr_new"
      fi
      echo
    fi
  done
fi

# -------- update manifest --------
echo "Updating manifest paths in: $MANIFEST"

if [ $APPLY -eq 1 ]; then
  # backup once
  cp -v -- "$MANIFEST" "$MANIFEST.bak"
  # perl inplace edit: replace space before .pdf at end of token/string
  # Handles:  path: "… .pdf"   or   '… .pdf'   or   … .pdf<end>
  # Case-insensitive to catch .PDF
  perl -i -pe 's/ \.pdf(?=(?:"|'\''|$))/\.pdf/ig' "$MANIFEST"
  echo "Manifest updated. Backup at: $MANIFEST.bak"
else
  echo "(dry-run) Would execute:"
  echo "  perl -i -pe 's/ \\.pdf(?=(?:\"|'\''|$))/\\.pdf/ig' \"$MANIFEST\""
fi

echo
echo "Done. Files changed: $changes  (mode: $([ $APPLY -eq 1 ] && echo APPLY || echo DRY-RUN))"