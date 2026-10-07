# AGENTS.md

This repo defines conventions for all others. Changes here have wide blast radius.

## Commands

```bash
make test    # shellcheck, opa/conftest unit tests, audit of a generated sample repo
```

## Rules

- Every rule in `docs/conventions.md` names its enforcement. Do not add a rule without one.
- Every `.rego` policy has a test in `policies/terraform/*_test.rego`. Policy change without a test is not done.
- Changing a rule: update `docs/conventions.md`, `template/AGENTS.md` and `template/.github/copilot-instructions.md` together, bump `VERSION`, add an ADR if non-obvious.
- Keep scripts plain bash with `set -euo pipefail`. No new dependencies without an ADR.
- Never put secrets or personal data here. The repo is public.
- Do not edit `template/` placeholders (`__REPO_NAME__`, `__DESCRIPTION__`, `__OWNER__`, `__DATE__`) without updating `new-repo.sh`.
