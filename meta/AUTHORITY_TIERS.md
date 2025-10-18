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

- ## [AMENDMENT] Assistant-to-Assistant Communication (Controlled Exception)

This amendment adds a controlled exception to the longstanding "assistants communicate via Nick (relay)" rule by describing the conditions under which controlled direct assistant-to-assistant communication may be enabled.

Effective immediately upon Tier 0 approval and commit, the following policy defines a controlled mechanism that allows, in specific circumstances, direct assistant-to-assistant communication routed through an approved mediator ("Orchestrator"). This policy does not remove Tier 0 authority or the requirement for Nick approval where specified below.

### Default rule (unchanged)
- Inter-assistant communication remains by default performed via Nick (relay).
- Assistants SHALL NOT directly message each other unless all conditions in this amendment are satisfied.

### Conditions for enabling direct, mediated assistant-to-assistant communication
Direct assistant-to-assistant communication MAY be enabled only if ALL of the following are true:

1. Tier 0 Authorization
   - Nick (Tier 0) MUST approve the enabling change. Approval MUST be recorded as a commit to this repository referencing the enabling commit SHA and date.
   - The commit message MUST reference: "Enable mediated assistant-to-assistant communication (orchestrator) — authorized by Nick".

2. Approved Mediator
   - All direct assistant-to-assistant messages MUST be routed through an approved mediator (the "Orchestrator").
   - The Orchestrator MUST enforce authentication, authorization, message-scope restrictions, and immutably-log all exchanges.

3. Scope & Allowed Message Types
   - The scope of messages allowed for direct exchange must be explicitly defined in the enabling commit and in assistant configuration files.
   - High-risk actions (file writes, git operations, script executions, destructive operations) must still require explicit Nick approval and MAY NOT be automatically executed by assistants without an explicit Tier 0 trigger.

4. Audit & Retention
   - All mediator traffic MUST be recorded to an append-only audit log.
   - Audit logs MUST be retained for a minimum of 365 days and available to Nick on request.
   - Logs MUST include: timestamp (UTC), sender assistant id, receiver assistant id, message id, message hash, operation scope, and the commit SHA (if message resulted in a repository change).

5. Approval Gates & Kill-switch
   - Any message classified as "High-risk" or "Destructive" must include an explicit approval token generated by Nick (or Nick's authorized delegate) before any assistant executes downstream actions.
   - A kill-switch mechanism MUST be available to immediately disable the Orchestrator and revoke keys.

6. Secrets & Sensitive Data
   - Assistants MUST NEVER exchange secrets or credentials in plaintext via the Orchestrator.
   - Any secret or credential movement must use an approved secrets-management procedure and be logged.

7. Minimal Viable Implementation (MVP) Requirements — before enabling
   - The Orchestrator MUST implement:
     - Mutual authentication (per-assistant keys / JWT)
     - Per-assistant scoping policies
     - Append-only audit logs (off-assistant, tamper-evident)
     - Rate-limiting and monitoring
     - Kill-switch and key revocation
   - An explicit test plan and pilot period (14 days) MUST be recorded in the enabling commit or PR.

### Rollout & Reversion
- Any enabling change MUST be submitted as a PR and include:
  - Updated assistant-configs/*/config.yaml describing the mediator and scope
  - Orchestrator spec and deployment checklist (docs/orchestrator/)
  - A runtime test plan and rollback steps
- If unexpected behavior or policy violation is detected, Nick may revoke the enabling commit and the Orchestrator keys; such revocation MUST be logged and tracked in the repository.

### Audit & Oversight
- KingSchultz and DjangoGPT are responsible for monitoring "Pending Git Sync" and may raise alerts if orchestrator-mediated exchanges affect Tier 2 docs.
- Copilot retains primary authority over repository structure decisions; any orchestrator-mediated structural change must still follow Copilot's suggestion/validation protocol.

---

## Amendment Log
- 2025-10-18 — Amendment added: Controlled assistant-to-assistant communication via approved mediator (Orchestrator). Authorized: Nick (pending commit to record explicit approval).
