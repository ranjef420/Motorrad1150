#!/usr/bin/env bash
set -euo pipefail

# Full-text search CLI over parts/index.sqlite with extras filters.
#
# USAGE:
#   query.sh [OPTIONS] -- QUERY TERMS
#
# Options:
#   -d, --db PATH         Path to index.sqlite (default: /Users/nickwade/Repos/Broomhilda/parts/index.sqlite)
#   -g, --group N         Restrict to BMW group number (e.g., 34)
#   -l, --limit N         Max rows to return (default 25)
#       --exact           Treat the whole query as an exact phrase for FTS
#       --json            Emit JSON (does not rely on sqlite .mode json)
#       --fields          Include extras fields in JSON output
#       --title STR       Filter title LIKE %STR%
#       --path STR        Filter path  LIKE %STR%
#       --tags STR        Filter extras.tags LIKE %STR%
#       --part STR        Filter extras.part_numbers LIKE %STR%
#       --notes STR       Filter extras.notes LIKE %STR%
#       --realoem STR     Filter extras.realoem LIKE %STR%
#       --order MODE      Sorting: bm25 | title | group (default: group)
#   -h, --help            Show this help
#
# Examples:
#   query.sh -- "integral abs front"
#   query.sh -g 34 -- "wheel speed sensor"
#   query.sh --exact -- "Front Wheel Brake – Integral ABS"
#   query.sh --json -l 5 --tags abs -- "modulator"
#   query.sh --title "crowngear" --json -- "rear axle"

# Prefer Homebrew sqlite (has FTS5/JSON built in), but fall back to PATH.
SQLITE3_BIN="${SQLITE3_BIN:-/opt/homebrew/opt/sqlite/bin/sqlite3}"
if ! command -v "$SQLITE3_BIN" >/dev/null 2>&1; then
  SQLITE3_BIN="$(command -v sqlite3 || true)"
fi
[ -n "$SQLITE3_BIN" ] || { echo "ERROR: sqlite3 not found." >&2; exit 1; }

ROOT="${ROOT:-/Users/nickwade/Repos/Broomhilda}"
DB="${DB:-$ROOT/parts/index.sqlite}"
GROUP=""
LIMIT=25
EXACT=0
JSON=0
FIELDS=0
TITLE=""
PATHLIKE=""
TAGS=""
PARTS=""
NOTES=""
REALOEM=""
ORDER="group"

usage() { sed -n '1,60p' "$0" | sed -n 's/^# \{0,1\}//p' | sed '1,20!d'; exit 0; }

# Parse args
args=()
while [ $# -gt 0 ]; do
  case "$1" in
    -d|--db) DB="$2"; shift 2;;
    -g|--group) GROUP="$2"; shift 2;;
    -l|--limit) LIMIT="$2"; shift 2;;
    --exact) EXACT=1; shift;;
    --json) JSON=1; shift;;
    --fields) FIELDS=1; shift;;
    --title) TITLE="$2"; shift 2;;
    --path) PATHLIKE="$2"; shift 2;;
    --tags) TAGS="$2"; shift 2;;
    --part) PARTS="$2"; shift 2;;
    --notes) NOTES="$2"; shift 2;;
    --realoem) REALOEM="$2"; shift 2;;
    --order) ORDER="$2"; shift 2;;
    -h|--help) usage;;
    --) shift; while [ $# -gt 0 ]; do args+=("$1"); shift; done; break;;
    *) args+=("$1"); shift;;
  esac
done

[ -f "$DB" ] || { echo "error: DB not found: $DB" >&2; exit 1; }
[ "${#args[@]}" -gt 0 ] || { echo "error: missing query terms (use -- to separate options from terms)" >&2; usage; }

# Assemble FTS query
Q="${args[*]}"
# Escape single quotes for SQL literal
ESC_Q=$(printf "%s" "$Q" | sed "s/'/''/g")
FTS_EXPR="$ESC_Q"
[ "$EXACT" -eq 1 ] && FTS_EXPR="\"$ESC_Q\""

# Base: from a view that already LEFT JOINs extras
# (create once if missing)
"$SQLITE3_BIN" "$DB" '
CREATE VIEW IF NOT EXISTS docs_view AS
SELECT d.group_no, d.title, d.diagram, d.path, d.body,
       e.part_numbers, e.realoem, e.notes, e.tags
FROM docs d LEFT JOIN extras e USING (path);
' >/dev/null 2>&1 || true

# WHERE clauses
WHERE="(docs MATCH '$FTS_EXPR')"
[ -n "$GROUP" ]     && WHERE="$WHERE AND group_no = $(printf "%s" "$GROUP" | tr -cd '0-9')"
[ -n "$TITLE" ]     && WHERE="$WHERE AND title LIKE '%' || $(printf "%s" "$TITLE" | "$SQLITE3_BIN" -cmd '') || '%'"
[ -n "$PATHLIKE" ]  && WHERE="$WHERE AND path  LIKE '%' || $(printf "%s" "$PATHLIKE" | "$SQLITE3_BIN" -cmd '') || '%'"
[ -n "$TAGS" ]      && WHERE="$WHERE AND IFNULL(tags,'') LIKE '%' || $(printf "%s" "$TAGS" | "$SQLITE3_BIN" -cmd '') || '%'"
[ -n "$PARTS" ]     && WHERE="$WHERE AND IFNULL(part_numbers,'') LIKE '%' || $(printf "%s" "$PARTS" | "$SQLITE3_BIN" -cmd '') || '%'"
[ -n "$NOTES" ]     && WHERE="$WHERE AND IFNULL(notes,'') LIKE '%' || $(printf "%s" "$NOTES" | "$SQLITE3_BIN" -cmd '') || '%'"
[ -n "$REALOEM" ]   && WHERE="$WHERE AND IFNULL(realoem,'') LIKE '%' || $(printf "%s" "$REALOEM" | "$SQLITE3_BIN" -cmd '') || '%'"

# ORDER BY
case "$ORDER" in
  bm25) ORDER_BY="ORDER BY bm25(docs) ASC";;
  title) ORDER_BY="ORDER BY title COLLATE NOCASE";;
  group|*) ORDER_BY="ORDER BY group_no, title COLLATE NOCASE";;
esac

# SELECT columns
if [ "$JSON" -eq 1 ]; then
  if [ "$FIELDS" -eq 1 ]; then
    SELECT_CLAUSE="json_object(
      'group_no', group_no,
      'title', title,
      'diagram', diagram,
      'path', path,
      'part_numbers', part_numbers,
      'realoem', realoem,
      'notes', notes,
      'tags', tags
    )"
  else
    SELECT_CLAUSE="json_object(
      'group_no', group_no,
      'title', title,
      'diagram', diagram,
      'path', path
    )"
  fi

  SQL="
  SELECT $SELECT_CLAUSE
  FROM docs_view
  WHERE $WHERE
  $ORDER_BY
  LIMIT $(printf "%s" "$LIMIT" | tr -cd '0-9');
  "

  # Emit JSON array
  printf "[\n"
  sep=""
  "$SQLITE3_BIN" "$DB" "$SQL" | while IFS= read -r line; do
    [ -z "$line" ] && continue
    printf "%s%s" "$sep" "$line"
    sep=",\n"
  done
  printf "\n]\n"

else
  # CSV text (safe default)
  SQL="
  SELECT group_no, title, diagram, path
  FROM docs_view
  WHERE $WHERE
  $ORDER_BY
  LIMIT $(printf "%s" "$LIMIT" | tr -cd '0-9');
  "
  "$SQLITE3_BIN" -csv "$DB" "$SQL"
fi