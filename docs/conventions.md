# Conventions

Every rule has an ID, a level, and an **enforcement** column. A rule with no automated enforcement is a wish, so each one says how it gets checked.

- **MUST**: a violation fails CI or blocks merge.
- **SHOULD**: a violation needs a one-line justification in the PR.
- Enforcement: `CI` = automated check, `PR` = human review (PR template checkbox), `BOOT` = set up by `new-repo.sh`.

## 1. Repository

| ID | Level | Rule | Enforcement |
|---|---|---|---|
| REPO-1 | MUST | Created from `template/` via `scripts/new-repo.sh`, never from an empty dir | BOOT |
| REPO-2 | MUST | Contains `README.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.github/CODEOWNERS`, `.github/pull_request_template.md`, `.governance-version` | CI (`audit-repo.sh`) |
| REPO-3 | MUST | README starts with: what it is, why it exists, how to run it, estimated monthly cost | PR |
| REPO-4 | MUST | Repo name is `kebab-case`, prefixed by domain: `lab-`, `tool-`, `poc-`, `platform-` | BOOT |
| REPO-5 | SHOULD | Every repo has a `Status:` line in README: `active`, `parked`, or `archived` | PR |

## 2. Git and pull requests

| ID | Level | Rule | Enforcement |
|---|---|---|---|
| GIT-1 | MUST | `main` is protected: PR required, status checks green, no force push | BOOT |
| GIT-2 | MUST | One intent per PR. Target under 400 changed lines excluding lockfiles | PR |
| GIT-3 | MUST | PR title follows Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `ci:`) | CI |
| GIT-4 | MUST | PR body has `## Why` (intent), `## What`, `## Risk / rollback` | CI (section check) |
| GIT-5 | MUST | PRs with AI-generated code say so under `## AI involvement` and state what you verified yourself | PR |
| GIT-6 | SHOULD | Squash merge, linear history | BOOT |

## 3. Azure and Terraform

| ID | Level | Rule | Enforcement |
|---|---|---|---|
| TF-1 | MUST | `terraform fmt -check`, `validate`, `tflint` pass | CI |
| TF-2 | MUST | Checkov (or Trivy config) passes. Suppressions need an inline `# checkov:skip=ID: reason` | CI |
| TF-3 | MUST | Conftest policies in `policies/terraform/` pass against the **plan JSON**, between plan and apply | CI |
| TF-4 | MUST | Resource names: `<type>-<prefix>-<env>`, with the CAF abbreviation (`rg`, `vnet`, `snet`, `aks`, `kv`, `st`). Globally-unique names (ACR, storage) drop hyphens | CI (rego) |
| TF-5 | MUST | Tags on every taggable resource: `project`, `env`, `owner`, `managed-by=terraform` | CI (rego) |
| TF-6 | MUST | Remote state in `rg-terraform-state` / `umairdevopsstate`, one `key` per repo | PR |
| TF-7 | MUST | No secrets in `.tf`, `.tfvars`, or state outputs. Use Key Vault + Workload Identity | CI (gitleaks) |
| TF-8 | MUST | CI authenticates with OIDC federated credentials, not a client secret | PR |
| TF-9 | MUST | Anything stateful (DB, KV, AKS, ACR) has `lifecycle.prevent_destroy = true` | CI (rego) |
| TF-10 | SHOULD | Allowed regions: `francecentral`, `westeurope`. Anything else needs justification | CI (rego) |
| TF-11 | SHOULD | Modules pinned by version or commit, providers pinned with `~>` | CI (tflint) |
| TF-12 | MUST | Public network access disabled on data services unless the PR says why | CI (rego) |

## 4. Kubernetes and delivery

| ID | Level | Rule | Enforcement |
|---|---|---|---|
| K8S-1 | MUST | GitOps: cluster state changes go through ArgoCD, not `kubectl apply` | PR |
| K8S-2 | MUST | Every workload sets CPU and memory requests and limits (including sidecars) | CI (Kyverno or kubeconform + rego) |
| K8S-3 | MUST | Namespaces start with a default-deny NetworkPolicy | PR |
| K8S-4 | MUST | Images pinned by tag or digest, never `latest` | CI |
| K8S-5 | SHOULD | Gateway API over classic Ingress | PR |
| K8S-6 | MUST | Optional heavy stacks are toggled by file presence in `apps-catalog/` or `replicas: 0` | PR |

## 5. Security

| ID | Level | Rule | Enforcement |
|---|---|---|---|
| SEC-1 | MUST | `gitleaks` on every PR and in pre-commit | CI |
| SEC-2 | MUST | Dependabot enabled for `github-actions`, `terraform`, and the repo's language ecosystem | BOOT |
| SEC-3 | MUST | Actions pinned to a major version at minimum, third-party actions pinned to SHA | CI (rego/script) |
| SEC-4 | MUST | Workflow `permissions:` declared explicitly, default `contents: read` | CI |
| SEC-5 | MUST | Tokens: fine-grained, repo-scoped, expiry noted in README under "Rotations" | PR |

## 6. Documentation and decisions

| ID | Level | Rule | Enforcement |
|---|---|---|---|
| DOC-1 | MUST | Non-obvious decisions get an ADR in `docs/adr/NNNN-title.md` (template provided) | PR |
| DOC-2 | MUST | README has a Roadmap checklist of open work, kept current | PR |
| DOC-3 | SHOULD | Diagrams as Mermaid in the repo, not exported images | PR |
| DOC-4 | MUST | Runbook (`docs/runbook.md`) for anything left running | PR |

## 7. Cost

| ID | Level | Rule | Enforcement |
|---|---|---|---|
| COST-1 | MUST | README states the monthly cost of leaving it running | PR |
| COST-2 | MUST | Anything billing continuously has a budget alert or an auto-stop/destroy mechanism | PR |
| COST-3 | SHOULD | Prefer serverless / auto-pause SKUs; otherwise schedule stop/start | PR |

## 8. Working with AI

See [ai-usage.md](ai-usage.md). Summary: AI output is untrusted input. It gets the same gates as hand-written code, plus a stated intent, plus a human who can explain every line before merge.

## Changing these conventions

Open a PR to this repo with an ADR. Bump `VERSION` (semver: major = breaking rule change, minor = new rule, patch = wording). Downstream repos see the drift via `scripts/audit-repo.sh`, which compares `.governance-version`.
