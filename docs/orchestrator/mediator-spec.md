```markdown
# Orchestrator (Mediator) — Spec & Minimal Implementation Plan

Status: Draft (for PR)

Purpose
-------
Provide a secure, auditable mediator that allows controlled assistant-to-assistant messaging under Tier 0 authorization. The Orchestrator enforces policies, scopes requests, and produces an append-only audit log. It does NOT execute repository-side actions automatically; it is a routing and policy-enforcement layer.

Principles
- Everything is explicit: every allowed exchange and scope must be declared in repository governance and assistant configs.
- Minimal privilege: assistants get the least privilege needed to exchange analysis or metadata.
- Auditable: every message and approval is logged and retained.
- Approval gates: high-risk/destructive actions require explicit Nick-issued tokens.
- Fail-closed: if Orchestrator becomes unavailable, the system falls back to the Nick relay policy.

High-level architecture
- API Gateway (TLS)
- AuthN/AuthZ service (JWT provider or mTLS)
- Policy Engine (enforces per-assistant scope)
- Message Router & Queue (durable, short TTL)
- Append-only Audit Store (immutable log, e.g., write-once S3 + checksum, or ledger DB)
- Admin Console (for issuing approval tokens, revoking keys, viewing audit logs)
- Kill-switch & Key Revocation subsystem

Minimal API (MVP)
- POST /v1/messages
  - Purpose: Send a message envelope from one assistant to another
  - Auth: Assistant JWT (client-credentials)
  - Body: JSON
    {
      "request_id": "uuid-v4",
      "sender": "copilot",
      "receiver": "kingschultz",
      "sensitivity_level": "low|medium|high|destructive",
      "summary": "short text summary (<= 256 chars)",
      "payload": { "type": "...", "data": { ... } },
      "referenced_paths": ["/dynamic/foo.yaml"]
    }
  - Response: 202 Accepted (queued), with message_id and audit log reference

- GET /v1/messages/{message_id}
  - Purpose: Retrieve message status and audit entry
  - Auth: Assistant JWT or admin token (with additional RBAC for audit)

- POST /v1/approvals
  - Purpose: Nick issues an approval token for a specific request_id
  - Body: { "request_id": "...", "approved_by": "nick", "expires_at": "ISO8601", "scope": "...", "signature": "..." }
  - Use: assistants must include approval token when executing high-risk flows (the orchestrator will verify token validity)

- GET /v1/audit/{message_id}
  - Purpose: Retrieve the append-only audit log entry for a message
  - Auth: admin (Nick) or delegated viewer roles

Security model
- AuthN: Per-assistant client credentials (private key or secret) used to obtain short-lived JWTs from an Orchestrator-auth service.
- AuthZ: Policy engine validates that a sender is allowed to target a receiver for the requested message_type and sensitivity_level.
- Transport: TLS 1.2+ mandatory. mTLS optional for additional assurance.
- Secrets: Store in a secrets manager (HashiCorp Vault, AWS Secrets Manager). No secrets in messages.

Audit & retention
- Audit entries are written to an append-only store (S3 with object-lock, WORM mode, or secure ledger DB).
- Retention: 365 days minimum.
- Audit entry fields:
  - timestamp_utc, message_id, request_id, sender, receiver, message_hash (SHA256), summary, sensitivity_level, policy_decision, approval_token (if used), related_commit_sha (if any)

Message schema and size limits
- Summary (<= 256 chars)
- Payload must be bounded (<= 64 KiB). Large payloads should be stored in a secured artifact store; the message references the artifact path.
- 'payload.type' ENUM: ["schema-validation-request", "schema-validation-result", "parts-query-request", "parts-query-result", "script-validation-request", "script-validation-result", "metadata-update", "notification"]

Approval gates & classification
- Classify messages into: low, medium, high, destructive.
- low/medium: allowed to route without Nick approval (subject to policy).
- high: requires Nick approval token from /v1/approvals.
- destructive: always blocked unless explicit Nick token and explicit PR/commit is created and approved.

Operational checklist for enabling (MVP)
1. Create a PR that:
   - Updates AUTHORITY_TIERS.md with the controlled exception (this PR).
   - Adds assistant-configs/* patches declaring orchestrator metadata and scope (this PR).
   - Adds this Orchestrator spec and deployment checklist (this PR).
2. Deploy Orchestrator in staging:
   - Containerized service (Docker), fronted by ingress with TLS.
   - Secrets in Vault.
   - Audit store configured (S3 object-lock or ledger DB).
3. Run pilot:
   - 14-day pilot with only low/medium message types enabled.
   - Monitor logs, behavior, and coordinator alerts.
4. Expand scope:
   - After pilot success, submit a follow-up PR to enable mediated_communication.enabled_by_default: true and document production URLs and keys rotation policy.
5. Rollback plan:
   - Revoke keys (kill-switch).
   - Revert enabling commit (Tier 0 must commit).
   - Restore previous relay-only behavior.

Minimal PoC implementation (tech stack suggestion)
- API: Node.js + Express or Python + FastAPI
- Auth: JWT with RSA keys; tokens issued by Orchestrator's auth service
- Queue: Redis or RabbitMQ for routing
- Audit store: S3 with object-lock or PostgreSQL append-only table with checksum
- Vault: HashiCorp Vault or cloud-managed secrets
- Container orchestration: Docker Compose for PoC; Kubernetes for production
- Observability: Prometheus + Grafana; alerting to owner's Slack/email

Developer notes
- Orchestrator MUST NOT be given authority to perform git operations on behalf of assistants.
- All write actions to repository continue to require Nick to perform git operations or explicit PR approvals.
- Assistants may prepare diffs or commands; the Orchestrator may transmit those artifacts as metadata but NOT run them.

Open items (for PR discussion)
- Finalize the allowed message_type ENUM values and payload size limits.
- Decide the audit retention policy beyond 365 days.
- Select the concrete Orchestrator deployment target and DNS.
```
