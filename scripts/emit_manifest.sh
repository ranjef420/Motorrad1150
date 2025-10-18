#!/usr/bin/env bash
set -euo pipefail

# Prefer Homebrew sqlite (has FTS5/JSON built in), but fall back to PATH.
SQLITE3_BIN="${SQLITE3_BIN:-/opt/homebrew/opt/sqlite/bin/sqlite3}"
if ! command -v "$SQLITE3_BIN" >/dev/null 2>&1; then
  SQLITE3_BIN="$(command -v sqlite3 || true)"
fi
[ -n "$SQLITE3_BIN" ] || { echo "ERROR: sqlite3 not found." >&2; exit 1; }

# Usage:
#   ./emit_manifest.sh
#   OUT=/tmp/MANIFEST.test.yaml ./emit_manifest.sh          # write elsewhere (safe local test)
#   DB=/tmp/hilde_index.test.sqlite ./emit_manifest.sh      # read a test DB
#   SOURCE_ROOT="parts/pdf" ./emit_manifest.sh              # override source_root field

# Script lives at repo root: /Users/nickwade/Repos/Broomhilda/scripts/emit_manifest.sh
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Defaults (allow env overrides)
DB="${DB:-${ROOT_DIR}/parts/index.sqlite}"
OUT="${OUT:-${ROOT_DIR}/parts/MANIFEST.parts.yaml}"
SOURCE_ROOT="${SOURCE_ROOT:-parts/pdf}"

[ -f "$DB" ] || { echo "ERROR: DB not found at $DB" >&2; exit 1; }
mkdir -p "$(dirname "$OUT")"

# Write YAML header to OUT (single sink)
cat > "$OUT" <<YAML
# MANIFEST.parts.yaml (generated from index.sqlite)
schema: 1
model: "R1150RT (R22) — Type 0499 (Authority)"
source_root: "$SOURCE_ROOT"
conventions:
  id_format: "R22-0499-{group}-{slug}"
  group_dirs: ["11","12","13","16","17","18","21","23","31","32","33","34","35","36","46","51","52","61","62","63","65"]
entries:
YAML

# Dump rows as TAB-separated to avoid CSV quoting hell.
# Columns: group_no \t title \t diagram \t path
"$SQLITE3_BIN" -separator $'\t' "$DB" \
  "SELECT group_no, title, IFNULL(diagram,''), path
   FROM docs
   ORDER BY CAST(group_no AS INT), title;" \
| awk -v OUT="$OUT" '
  function tolower_ascii(s,  r,i,c){ r=""; for(i=1;i<=length(s);i++){c=substr(s,i,1); if(c>="A" && c<="Z"){c=tolower(c)}; r=r c} return r }
  function slugify(s,  t){ t=s; gsub(/[\r\n]/, "", t); t=tolower_ascii(t); gsub(/&/, " and ", t); gsub(/[^a-z0-9]+/, "-", t); gsub(/^-+|-+$/, "", t); return t }
  function yesc(s){ gsub(/\r/,"",s); gsub(/\\/,"\\\\",s); gsub(/"/,"\\\"",s); return s }
  BEGIN{ FS="\t"; }
  {
    group=$1; title=$2; diagram=$3; path=$4;
    slug = slugify(title)
    id = "R22-0499-" group "-" slug
    if (diagram != "" && diagram != " ") {
      gsub(/[^A-Za-z0-9_]/,"",diagram)
      id = id "-" diagram
    }
    title = yesc(title)
    path  = yesc(path)

    print "  - id: " id >> OUT
    print "    group: " group >> OUT
    print "    title: \"" title "\"" >> OUT
    if (diagram != "" && diagram != " ") {
      print "    diagram: \"" diagram "\"" >> OUT
    } else {
      print "    diagram: null" >> OUT
    }
    print "    path: \"" path "\"" >> OUT
    print "    aliases: []" >> OUT
    print "    tags: []" >> OUT
  }'

echo "Wrote $OUT"