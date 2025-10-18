#!/usr/bin/env bash
set -euo pipefail

# Prefer Homebrew sqlite (has FTS5/JSON built in), but fall back to PATH.
   SQLITE3_BIN="${SQLITE3_BIN:-/opt/homebrew/opt/sqlite/bin/sqlite3}"
   if ! command -v "$SQLITE3_BIN" >/dev/null 2>&1; then
     SQLITE3_BIN="$(command -v sqlite3 || true)"
   fi
   [ -n "$SQLITE3_BIN" ] || { echo "ERROR: sqlite3 not found." >&2; exit 1; }

ROOT="/Users/nickwade/Repos/Broomhilda"
MANIFEST="$ROOT/parts/MANIFEST.parts.yaml"   # put the manifest here (not at repo root)
OCR_DIR="$ROOT/parts_ocr"
DB="$ROOT/parts/index.sqlite"

# Use a Python venv so PyYAML works cleanly on macOS (PEP 668)
VENV="$ROOT/.venv"
PY="$VENV/bin/python3"

if [ ! -x "$PY" ]; then
  echo "• Creating Python venv at $VENV"
  python3 -m venv "$VENV"
  "$VENV/bin/pip" install --upgrade pip >/dev/null
  "$VENV/bin/pip" install pyyaml >/dev/null
fi

mkdir -p "$(dirname "$DB")"

# Generate a TSV of (group_no, title, diagram, path, body)
"$PY" - <<'PY' > /tmp/docs.tsv
import os, sys, yaml, pathlib

ROOT = "/Users/nickwade/Repos/Broomhilda"
MANIFEST = os.path.join(ROOT, "parts", "MANIFEST.parts.yaml")
OCR_DIR = os.path.join(ROOT, "parts_ocr")

with open(MANIFEST, "r", encoding="utf-8") as f:
    items = yaml.safe_load(f)

def read_body(rel_path):
    # rel_path is like "34 - Brakes/Front Wheel Brake – Integral ABS.pdf"
    txt = os.path.join(OCR_DIR, os.path.splitext(rel_path)[0] + ".txt")
    try:
        with open(txt, "r", encoding="utf-8", errors="ignore") as t:
            return t.read().replace("\0"," ")
    except FileNotFoundError:
        return ""

print("group_no\ttitle\tdiagram\tpath\tbody")  # header
for it in items:
    group_no = str(it.get("group_no","")).strip()
    title    = (it.get("title","") or "").strip()
    diagram  = (it.get("diagram","") or "").strip()
    path     = (it.get("path","") or "").replace("parts/pdf/","",1).strip()
    body     = read_body(path)
    print(f"{group_no}\t{title}\t{diagram}\t{path}\t{body}".replace("\n"," "))
PY

# (Re)create DB (FTS5 for 'body' + metadata; extras table for schema add-ons)
"$SQLITE3_BIN" "$DB" <<'SQL'
PRAGMA journal_mode=WAL;
DROP TABLE IF EXISTS docs;
DROP TABLE IF EXISTS docs_idx;
DROP TABLE IF EXISTS extras;
DROP VIEW  IF EXISTS docs_view;

-- Base row store
CREATE TABLE docs (
  id       INTEGER PRIMARY KEY,
  group_no INTEGER,
  title    TEXT,
  diagram  TEXT,
  path     TEXT,
  body     TEXT
);

-- FTS index on text columns
CREATE VIRTUAL TABLE docs_idx USING fts5(
  title, path, body, content='docs', content_rowid='id'
);

-- Trigger to sync docs -> fts
CREATE TRIGGER docs_ai AFTER INSERT ON docs BEGIN
  INSERT INTO docs_idx(rowid, title, path, body) VALUES (new.id, new.title, new.path, new.body);
END;
CREATE TRIGGER docs_ad AFTER DELETE ON docs BEGIN
  INSERT INTO docs_idx(docs_idx, rowid, title, path, body) VALUES('delete', old.id, old.title, old.path, old.body);
END;
CREATE TRIGGER docs_au AFTER UPDATE ON docs BEGIN
  INSERT INTO docs_idx(docs_idx, rowid, title, path, body) VALUES('delete', old.id, old.title, old.path, old.body);
  INSERT INTO docs_idx(rowid, title, path, body) VALUES (new.id, new.title, new.path, new.body);
END;

-- Schema extensions: lightweight extras keyed by path (unique)
CREATE TABLE extras (
  path TEXT PRIMARY KEY,
  part_numbers TEXT,  -- CSV or JSON string
  realoem TEXT,       -- URL or code
  notes TEXT,
  tags TEXT           -- CSV or JSON string
);

-- Unified view for downstream tools
CREATE VIEW docs_view AS
SELECT d.id, d.group_no, d.title, d.diagram, d.path,
       e.part_numbers, e.realoem, e.notes, e.tags
FROM docs d
LEFT JOIN extras e ON e.path = d.path;

SQL

# Load TSV
"$SQLITE3_BIN" "$DB" <<'SQL'
.mode tabs
.import /tmp/docs.tsv docs
SQL

echo "✔ Index built at $DB"