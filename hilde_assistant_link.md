hilde_assistant_link.md
───────────────────────────────────────────────────────────
PROJECT ENTITY: "Hilde"
───────────────────────────────────────────────────────────
vehicle_name_full: "Broomhilda"
alias: "Hilde"
vin: WB10499A14ZE93239
model: R1150RT
type: "Authority / Police"
type_code: 0499
color: "Night-Black" (nacht-schwarz, Zierl)
owner: "Nick (User)"
designation: "Primary Subject Motorcycle – AI Maintenance & Diagnostic Reference"
repository: "https://github.com/ranjef420/Broomhilda"

assistants_linked:
  - "DjangoGPT": Custom ChatGPT
  - Claude (Project/Code Integration: "KingSchultz")
  - GitHub Copilot

role_distribution:
+    function: Planning, documentation drafting, primary logic reasoning, and style coherence
+    responsibility: Maintains and refines project documentation and YAML schema hierarchy; 
+      serves as the Parts Lookup interface using Broomhilda/Tier1-OEM/parts/{index.sqlite, MANIFEST.parts.yaml}
  DjangoGPT:
function: Planning, documentation drafting, primary logic reasoning, and style coherence
+   responsibility: Maintains and refines project documentation and YAML schema hierarchy; 
+   serves as the Parts Lookup interface using Broomhilda/Tier1-OEM/parts/{index.sqlite, MANIFEST.parts.yaml}
   
  KingSchultz (Claude):
    function: Code reasoning, document validation, inter-assistant communication and translation
    +    responsibility: Ensures technical integrity and synchronization across assistants; 

  Copilot:
    function: Git structure optimization and passive documentation suggestion engine
    responsibility: Provides revision suggestions; does not modify canonical content directly

data_sources:
  - Git Repository (Primary): "https://github.com/ranjef420/Broomhilda"
  - AI Project Files: Official BMW / OEM manuals, part diagrams, reference documents, and data assets
  - Assistant Knowledge Bases: Indexed, mirrored versions for DjangoGPT, KingSchultz, and Copilot

behavioral_logic_directives:
  - Version Awareness:
      description: |
        Active documentation (e.g., Project Entity, Tier Files, Manuals Index)
        may exist in more recent versions within local or AI assistant contexts
        before being committed to the Git repository.
      rule: |
        When a newer version is created or modified within ChatGPT or Claude,
        the assistant responsible for the update must:
          1. Mark the document as "Pending Git Sync".
          2. Notify Nick to push the finalized update to the repository.
          3. Confirm synchronization once the Git commit has been verified.
      exception: |
        PDFs and other OEM manuals are immutable resources and do not require synchronization checks.

  - Data Access Redundancy:
      description: |
        All BMW Manuals and OEM PDFs (e.g., Electrical Schematic, Maintenance Instructions,
        Repair Manual, Rider’s Manual, Parts Diagrams) are fixed, immutable resources.
        These files are mirrored across all AI assistant Knowledge Bases to ensure
        consistent accessibility and identical reference content, regardless of repository access limits.
      rule: |
        If the Git repository cannot serve a document (e.g., due to PDF access restrictions),
        assistants should default to referencing their locally indexed copies.
        Local mirrors are considered authoritative if identical to the Git version.

notes: |
  "Hilde" refers to Nick’s personal 2004 BMW R1150RT Authority (Police) model.

  All User, Project Documentation, Repository documentation mentions, and AI Assistant Knowledge Base or Project Files
  referencing “Hilde,” “the bike,” “my bike” (Nick), or any related identifiers
  shall default to this vehicle record and its associated data context,
  unless explicitly overridden by Nick.

  The linked Git repository (https://github.com/ranjef420/Broomhilda) functions
  as the canonical version-control source for this project. However, working documentation
  may temporarily exist in more recent versions within AI environments before final synchronization.
  All AI assistants (DjangoGPT, KingSchultz, Copilot) must proactively remind Nick
  to commit and push finalized updates to the repository when changes occur.

  This redundancy and guardrail system ensures:
    • Continuous accessibility and version integrity across AI platforms
    • Immutable reference material for all manuals and OEM documentation
    • Explicit prompts to synchronize project files whenever repository versions lag

+      rule: |
+        Assistants must first use the repository’s index.sqlite and MANIFEST.parts.yaml.
+        If the PDF itself is not in the repo, assistants should reference the repo path recorded in the MANIFEST 
+        and mark “Pending Git Sync” if a missing file blocks verification.
+    
───────────────────────────────────────────────────────────
