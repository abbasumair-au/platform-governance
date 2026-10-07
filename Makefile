.PHONY: test shellcheck policies sample

test: shellcheck policies sample

shellcheck:
	@command -v shellcheck >/dev/null && shellcheck scripts/*.sh || echo "shellcheck not installed, skipped"

policies:
	@if command -v conftest >/dev/null; then conftest verify -p policies/terraform; \
	elif command -v opa >/dev/null; then opa test policies/terraform -v; \
	else echo "need conftest or opa"; exit 1; fi

sample:
	@d=$$(mktemp -d) && DEV_DIR=$$d scripts/new-repo.sh lab-sample "sample" >/dev/null \
	  && scripts/audit-repo.sh $$d/lab-sample && rm -rf $$d
