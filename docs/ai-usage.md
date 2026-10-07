# Working with AI

Principle from the big-tech pattern (Stripe, Spotify, Google, Meta): the AI works inside a hard frame of tests, CI, and ownership. The bottleneck is verification, not generation. So the frame is the product.

## Rules

1. **AI-generated IaC is untrusted by default.** Same gates as hand-written (TF-1..TF-3), no exceptions, no "it's just a lab".
2. **Policy-as-code sits between plan and apply.** An agent cannot talk its way past a failing Conftest policy.
3. **Instructions live in the repo.** `AGENTS.md` and `.github/copilot-instructions.md` carry the conventions so every agent session starts from the same rules. Update them when a rule changes, in the same PR.
4. **Small batches.** One intent per PR. DORA 2025 found AI raises throughput but hurts delivery stability unless batches stay small.
5. **State the intent.** Every PR has `## Why`. Reviewing code you cannot tie to an intent is how review debt accumulates.
6. **You must be able to explain every line before merging.** If you can't, ask the agent to explain it, or delete it.
7. **Deterministic first.** Lint, format, tests, scans run as plain tools, not as prompts. Use the agent for the parts that need judgment.
8. **Verify against reality.** `terraform validate` passing is not the same as the resource working. For anything deployed, record what you checked on the live system in the PR.
9. **Never give an agent standing production credentials.** Agents run with the read-only or lab-scoped identity; applies happen in CI.
10. **Curate context, don't dump it.** Keep `AGENTS.md` short and specific. Link to docs instead of pasting them.

## What `AGENTS.md` must contain

- One paragraph: what this repo is.
- Commands: how to build, test, lint, plan.
- Hard rules: the top conventions that apply here (pointing to rule IDs).
- Do-not-touch list: state files, generated files, protected resources.
- Definition of done.

## Measure it (monthly, 10 minutes)

| Metric | Why |
|---|---|
| PR review wait time | Meta found a 5% slowdown only by measuring |
| % of PRs failing CI first run | Shows whether agents respect the instructions |
| Rework rate (PRs reverted or followed by a fix within 7 days) | Quality signal that lead time hides |
| Policy violations caught by Conftest | Evidence the gate is doing real work |

Record the numbers in `docs/metrics.md` in each active repo. A short table is enough.
