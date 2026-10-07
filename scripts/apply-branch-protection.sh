#!/usr/bin/env bash
# GIT-1: protect main. Usage: apply-branch-protection.sh owner/repo
set -euo pipefail
repo="${1:?owner/repo}"

# Solo account: PR required but 0 approvals, since you cannot approve your own PR.
# Raise required_approving_review_count to 1 when a second human exists.
gh api -X PUT "repos/$repo/branches/main/protection" --input - <<'JSON' >/dev/null
{
  "required_status_checks": { "strict": true, "contexts": ["governance", "secrets"] },
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 0, "dismiss_stale_reviews": true },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
echo "Branch protection applied to $repo"
