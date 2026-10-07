#!/usr/bin/env bash
# Create a new repo from template/ with conventions pre-applied.
# Usage: scripts/new-repo.sh <name> "<one-line description>" [--push] [--public]
set -euo pipefail

GOV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV_DIR="${DEV_DIR:-$HOME/dev}"
OWNER="${GH_OWNER:-abbasumair-au}"

name="${1:?usage: new-repo.sh <name> \"<description>\" [--push] [--public]}"
desc="${2:?description required}"
shift 2
push=false; visibility=private
for a in "$@"; do
  case "$a" in
    --push) push=true ;;
    --public) visibility=public ;;
    *) echo "unknown flag $a" >&2; exit 2 ;;
  esac
done

if ! [[ "$name" =~ ^(lab|tool|poc|platform)-[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "REPO-4: name must be kebab-case with prefix lab-|tool-|poc-|platform- (got '$name')" >&2
  exit 1
fi

dest="$DEV_DIR/$name"
[[ -e "$dest" ]] && { echo "$dest already exists" >&2; exit 1; }

cp -r "$GOV_DIR/template" "$dest"
version="$(tr -d '[:space:]' < "$GOV_DIR/VERSION")"

cd "$dest"
echo "$version" > .governance-version
# Render placeholders
grep -rl '__REPO_NAME__\|__DESCRIPTION__\|__OWNER__\|__DATE__' . | while read -r f; do
  sed -i \
    -e "s|__REPO_NAME__|$name|g" \
    -e "s|__DESCRIPTION__|$desc|g" \
    -e "s|__OWNER__|$OWNER|g" \
    -e "s|__DATE__|$(date +%F)|g" "$f"
done
find . -name '*.tmpl' | while read -r f; do mv "$f" "${f%.tmpl}"; done

git init -q -b main
if [[ -z "$(git config user.name || true)" ]]; then
  export GIT_AUTHOR_NAME="$OWNER" GIT_COMMITTER_NAME="$OWNER"
  export GIT_AUTHOR_EMAIL="$OWNER@users.noreply.github.com" GIT_COMMITTER_EMAIL="$OWNER@users.noreply.github.com"
fi
git add -A
git -c commit.gpgsign=false commit -q -m "chore: bootstrap from platform-governance v$version"
echo "Created $dest (governance v$version)"

if $push; then
  gh repo create "$OWNER/$name" "--$visibility" --description "$desc" --source . --push
  "$GOV_DIR/scripts/apply-branch-protection.sh" "$OWNER/$name"
  gh api -X PUT "repos/$OWNER/$name/vulnerability-alerts" >/dev/null || true
  gh api -X PUT "repos/$OWNER/$name/automated-security-fixes" >/dev/null || true
  gh repo edit "$OWNER/$name" --delete-branch-on-merge --enable-squash-merge \
    --enable-merge-commit=false --enable-rebase-merge=false >/dev/null
  echo "Pushed and protected: https://github.com/$OWNER/$name"
else
  echo "Not pushed. Re-run with --push, or: cd $dest && gh repo create $OWNER/$name --$visibility --source . --push"
fi
