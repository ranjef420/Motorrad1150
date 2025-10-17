## Repo File Naming Templates

### OEM Manuals and PDF Handling
**Pattern:** `Hilde_R1150RT_<ManualType>.pdf`

---

## Functionality and Resources

### R1150RT Parts Database
Lightweight toolchain for indexing the Parts Database and converting static OEM PDF service manuals into a searchable knowledge system.

**Overview:**
- **Input:** OEM PDF diagrams stored under `parts/pdf/` (organized by group number)  
- **Process:** OCR extraction → SQLite FTS5 indexing via scripts  
- **Output:** `parts/index.sqlite` — full-text searchable database with diagram metadata  
- **Usage:** Query the index via `./scripts/query.sh`

**Future Enhancements:**
- Improve OCR accuracy through preprocessing (deskew, despeckle, binarize).  
- Implement caching to skip re-OCR of unchanged PDFs (using hash or `mtime`).  
- Add JSON output for front-end integration (`./scripts/query.sh --json ...`).  
- Extend schema to include part numbers, RealOEM references, and service notes.
