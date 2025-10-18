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

---

## Repo Structure:

Broomhilda/
├── .claude/                    # Claude settings (settings.json tracked)
├── .github/                    # GitHub workflows & templates
│   ├── workflows/              # CI/CD automation
│   ├── CODEOWNERS
│   └── PULL_REQUEST_TEMPLATE.md
├── assistant-configs/          # AI assistant configurations
│   ├── copilot/
│   │   └── config.yaml
│   ├── djangogpt/
│   │   └── config.yaml
│   └── kingschultz/
│       └── config.yaml
├── dynamic/                    # Working documents (AI-generated)
│   ├── README.md
│   ├── copilot_wiring-annotations_2025-10-15.json
│   ├── djangogpt_service-checklist_2025-10-15.md
│   └── kingschultz_diagnostics-schema_2025-10-15.yaml
├── manuals/                    # OEM Manuals (LFS tracked)
│   ├── Hilde_R1150RT_Build_Profile.txt
│   ├── Hilde_R1150RT_Electrical_Schematic.pdf
│   ├── Hilde_R1150RT_Maintenance_Instructions.pdf
│   ├── Hilde_R1150RT_Repair_Manual.pdf
│   └── Hilde_R1150RT_Riders_Manual.pdf
├── meta/                       # Reference indexes & authority docs
│   ├── AUTHORITY_TIERS.md
│   ├── CHANGELOG.md
│   └── REFERENCE_INDEX.yaml
├── parts/                      # Parts database & diagrams
│   ├── .gitattributes          # LFS config for parts PDFs
│   ├── MANIFEST.parts.yaml
│   ├── index.sqlite
│   ├── pdf/                    # 228 OEM parts diagrams (LFS)
│   │   ├── 11 - Engine/        (26 files)
│   │   ├── 12 - Engine Electrics/  (8 files)
│   │   ├── 13 - Fuel Preparation/  (5 files)
│   │   ├── 16 - Fuel Supply/   (10 files)
│   │   ├── 17 - Cooling/       (2 files)
│   │   ├── 18 - Exhaust System/  (3 files)
│   │   ├── 21 - Clutch/        (2 files)
│   │   ├── 23 - Transmission/  (9 files)
│   │   ├── 31 - Front Suspension/  (6 files)
│   │   ├── 32 - Steering/      (8 files)
│   │   ├── 33 - Rear Axle & Suspension/  (8 files)
│   │   ├── 34 - Brakes/        (10 files)
│   │   ├── 35 - Pedals/        (1 file)
│   │   ├── 36 - Wheels/        (2 files)
│   │   ├── 46 - Frame Fairing & Cases/  (45 files)
│   │   ├── 51 - Vehicle Trim/  (10 files)
│   │   ├── 52 - Seat/          (5 files)
│   │   ├── 61 - Electrical System/  (48 files)
│   │   ├── 62 - Instrument Dash/  (5 files)
│   │   ├── 63 - Lighting/      (12 files)
│   │   └── 65 - GPS Alarms & Radio/  (15 files)
│   └── scripts/                # Parts processing scripts
├── scripts/                    # Build & query utilities
│   ├── build_index.sh
│   ├── emit_manifest.sh
│   ├── ocr_all.sh
│   └── query.sh
├── .gitattributes              # LFS tracking rules
├── .gitignore                  # Exclusion rules
├── README.md                   # Project documentation
├── hilde_assistant_link.md     # Project entity & assistant roles
└── requirements.txt            # Python dependencies
