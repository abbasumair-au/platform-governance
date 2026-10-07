# 0001. One governance repo plus a template, not per-repo copies

Date: 2026-10-07
Status: accepted

## Context
Most code in this account is written with AI help. Quality depends on automated gates, not on remembering conventions. Repos were being created ad hoc, with different layouts, CI, and rules. Large engineering orgs (Stripe, Spotify, Google, Meta) keep AI output safe with deterministic verification around the agent, and measure the effect.

## Decision
Keep conventions, policies, reusable workflows, and a repo template in one public repo, `platform-governance`. New repos are generated with `scripts/new-repo.sh` and stamped with `.governance-version`. Existing repos are checked with `scripts/audit-repo.sh`.

## Alternatives considered
- **GitHub template repository only**: copies files once, then drifts. No policies, no audit.
- **Org-level `.github` repo with default files**: needs a GitHub organization. A personal account only supports a limited form of this.
- **Copy-paste from a wiki page**: no enforcement.
- **Backstage or a developer portal**: far too heavy for the scale.

## Consequences
- Easy: new repos start compliant. Conventions are versioned and diffable. Policies are testable.
- Harder: changing a rule means touching downstream repos. Mitigated by `audit-repo.sh` drift warnings.
- Public by necessity (cross-repo checkout with `GITHUB_TOKEN`). Nothing secret may ever live here.
- Reusable workflows are referenced at `@main` until `v1` is tagged. Pin to a tag after that.
