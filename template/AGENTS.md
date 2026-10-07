# AGENTS.md

Instructions for AI coding agents (Claude Code, Copilot, others). Conventions come from
[platform-governance](https://github.com/__OWNER__/platform-governance); rule IDs below refer to its `docs/conventions.md`.

## What this repo is

__DESCRIPTION__

## Commands

```bash
make fmt        # format
make lint       # fmt-check + tflint/ruff/etc.
make test       # unit/policy tests
make plan       # terraform plan (never apply locally)
```

(Edit the Makefile targets to match the stack. Keep these four names stable.)

## Hard rules

- Work on a branch, open a PR. Never push to `main` (GIT-1).
- One intent per PR, under ~400 lines (GIT-2). Fill `## Why`, `## What`, `## Risk / rollback`, `## AI involvement` (GIT-4, GIT-5).
- Terraform: names `<type>-<prefix>-<env>`, tags `project`, `env`, `owner`, `managed-by` on everything (TF-4, TF-5).
- Stateful resources get `lifecycle { prevent_destroy = true }` (TF-9).
- No secrets in code, tfvars, or logs. Key Vault + Workload Identity (TF-7, TF-8).
- Kubernetes workloads set CPU/memory requests and limits, including sidecars (K8S-2).
- Do not run `terraform apply`, `kubectl apply`, or `az ... delete` against shared environments. CI and ArgoCD do that.
- A suppression (`checkov:skip`, `tflint-ignore`) needs a written reason.

## Do not touch

- `*.tfstate*`, `.terraform/`, `.governance-version` (managed by the governance repo).
- Anything under `policies/` unless the task is about policies.

## Definition of done

1. `make lint test` passes.
2. For anything deployed: you checked the live result, and said how in the PR.
3. README, runbook, and ADR updated if behavior or a decision changed (DOC-1, DOC-4).
4. You can explain every changed line.
