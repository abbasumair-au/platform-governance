# Copilot instructions

Follow `AGENTS.md` in the repo root. Highlights for code review:

- Flag any Azure resource missing tags `project`, `env`, `owner`, `managed-by`.
- Flag resource names not matching `<type>-<prefix>-<env>` (CAF abbreviations).
- Flag stateful resources (SQL, Postgres, Key Vault, AKS, ACR) without `prevent_destroy = true`.
- Flag public network access enabled on data services.
- Flag secrets, client secrets, or long-lived tokens; prefer OIDC and Workload Identity.
- Flag Kubernetes containers without CPU/memory requests and limits.
- Flag GitHub Actions without explicit `permissions:` or not pinned to a version.
- Flag a PR that mixes unrelated changes; ask for it to be split.
- Do not approve on style alone. Prioritize correctness, security, and blast radius.
