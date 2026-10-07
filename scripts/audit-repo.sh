#!/usr/bin/env bash
# Check a repo against the structural conventions (REPO-2, GIT-4 template, drift).
# Usage: audit-repo.sh [path]   (default: current dir)
set -uo pipefail
root="$(cd "${1:-.}" && pwd)"
gov_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

need() {
  if [[ ! -e "$root/$1" ]]; then echo "FAIL REPO-2: missing $1"; fail=1; fi
}

for f in README.md AGENTS.md .github/copilot-instructions.md .github/CODEOWNERS \
         .github/pull_request_template.md .governance-version .gitignore; do
  need "$f"
done

if [[ -f "$root/README.md" ]]; then
  grep -qi '^status:' "$root/README.md" || { echo "WARN REPO-5: README has no 'Status:' line"; }
  grep -qi 'cost' "$root/README.md" || { echo "FAIL COST-1: README never mentions cost"; fail=1; }
fi

if [[ -f "$root/.github/pull_request_template.md" ]]; then
  for s in '## Why' '## What' '## Risk' '## AI involvement'; do
    grep -q "$s" "$root/.github/pull_request_template.md" || { echo "FAIL GIT-4/5: PR template lacks '$s'"; fail=1; }
  done
fi

# SEC-4: every workflow declares permissions.
if compgen -G "$root/.github/workflows/*.yml" >/dev/null; then
  for w in "$root"/.github/workflows/*.yml; do
    grep -q '^permissions:' "$w" || { echo "FAIL SEC-4: $(basename "$w") has no top-level permissions:"; fail=1; }
  done
fi

# TF-9: stateful resources need prevent_destroy.
if compgen -G "$root/**/*.tf" >/dev/null || find "$root" -name '*.tf' -not -path '*/.terraform/*' | grep -q .; then
  "$gov_dir/scripts/check-prevent-destroy.sh" "$root" || fail=1
fi

# Drift
if [[ -f "$root/.governance-version" ]]; then
  have="$(tr -d '[:space:]' < "$root/.governance-version")"
  want="$(tr -d '[:space:]' < "$gov_dir/VERSION")"
  [[ "$have" == "$want" ]] || echo "WARN drift: repo on governance v$have, current is v$want"
fi

[[ $fail -eq 0 ]] && echo "audit OK: $root" || { echo "audit FAILED: $root"; exit 1; }
