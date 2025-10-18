# AUTHORITY TIERS – BROOMHILDA PROJECT (HILDE, R1150RT 0499)

This document defines the Tier authority hierarchy governing all materials, data, and generated content
within the Broomhilda repository and the rules that govern who can change what. Each tier establishes a level of reliability, mutability, and precedence
for reference, documentation, and synchronization across AI assistants.

---

## TIER 0 — PROJECT META / GOVERNANCE
**Authority:** Absolute  
**Location:** `/meta/`, `/assistant-configs/`, `project_header.yml`, `hilde_assistant_link.md`  
**Scope:** Defines project identity, assistant roles, data relationships, and synchronization logic.  
**Editable by:** DjangoGPT (primary), KingSchultz (review), Nick (override)

**Includes:**
- `project_header.yml`
- `hilde_assistant_link.md`
- `.claude/settings.json`
- `AUTHORITY_TIERS.md`
- Any assistant configuration (`/assistant-configs/*/config.yaml`)

**Rules:**
- These files define the canonical truth for all assistants and data flows.
- Edits require explicit confirmation and `Pending Git Sync` marking.
- If conflict arises between Tiers, Tier 0 takes precedence.

---

## TIER 1 — OEM / OFFICIAL REFERENCES
**Authority:** Immutable (Canonical Technical Source)  
**Location:** `/manuals/`  
**Scope:** Official BMW Motorrad documentation and diagrams.  
**Editable by:** None (read-only)

**Includes:**
- `Hilde_R1150RT_Repair_Manual.pdf`
- `Hilde_R1150RT_Riders_Manual.pdf`
- `Hilde_R1150RT_Maintenance_Instructions.pdf`
- `Hilde_R1150RT_Electrical_Schematic.pdf`

**Rules:**
- Never edited or modified.  
- Serve as the ultimate technical authority for all specifications.  
- Mirrored across AI assistant knowledge bases to ensure availability.

---

## TIER 2 — PROJECT-DEFINED DOCUMENTATION
**Authority:** High (Dynamic Canonical Source)  
**Location:** `/dynamic/`, `/assistant-configs/`, `/meta/`  
**Scope:** Documents authored or refined by AI assistants and/or Nick that define interpretation,
application, or extension of OEM data.

**Includes:**
- Assistant working documents and YAML schemas  
- Diagnostic flowcharts, maintenance logs, and procedural writeups  
- Structured templates or generated analysis derived from manuals

**Rules:**
- Editable under assistant collaboration (DjangoGPT + KingSchultz)
- Must reference Tier 1 sources where applicable
- Updated versions flagged as `Pending Git Sync` until committed

---

## TIER 3 — PROJECT OUTPUTS & ANALYSES
**Authority:** Moderate (Operational / Draft Data)  
**Location:** `/dynamic/`  
**Scope:** Interim working data, assistant-generated proposals, and analysis in progress.

**Includes:**
- Temporary AI outputs  
- Sandbox YAML or Markdown drafts  
- Experimental scripts or comparisons

**Rules:**
- Subject to frequent change  
- Must not overwrite Tiers 0–2  
- Can be freely restructured or pruned after verification

---

## TIER 4 — EXTERNAL / SUPPLEMENTAL RESOURCES
**Authority:** Reference Only  
**Location:** External (forums, articles, datasets, external repos)  
**Scope:** External data sources used for supplemental interpretation or validation.

**Rules:**
- Never override OEM or project-defined content  
- Require manual citation and provenance tracking  
- Treated as advisory only

---

## PRECEDENCE HIERARCHY SUMMARY

| Tier | Name / Description              | Authority | Editable | Examples |
|------|----------------------------------|------------|-----------|-----------|
| 0 | Project Meta / Governance | **Absolute** | Controlled | `project_header.yml`, `AUTHORITY_TIERS.md` |
| 1 | OEM / Official References | **Immutable** | None | BMW manuals, schematics |
| 2 | Project-Defined Docs | **High** | Yes (controlled) | YAML schemas, service checklists |
| 3 | Working / AI Outputs | **Moderate** | Yes | Dynamic analysis, AI drafts |
| 4 | External References | **Advisory** | No | Forum posts, public data |

---

## SYNCHRONIZATION LOGIC
- Tier 0 changes must trigger sync reminders to update the Git repository.  
- Tier 1 files are exempt from sync tracking (immutable).  
- Tier 2–3 files must include version and assistant origin tags.  
- Tier 4 references are never committed directly; cited only in documentation.

---

## NOTES
- All assistants (DjangoGPT, KingSchultz, Copilot) must respect this hierarchy when generating, revising, or validating project content.  
- If ambiguity exists, defer to Nick or Tier 0 documentation.  
- Tier 1 materials always override assistant or AI-generated content.  
- Tier 0 governs the interpretation of all other tiers.
