.PHONY: fmt lint test plan audit

TF_DIR ?= terraform
GOV    ?= $(HOME)/dev/platform-governance

fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

lint:
	terraform -chdir=$(TF_DIR) fmt -check -recursive
	@command -v tflint >/dev/null && (cd $(TF_DIR) && tflint --init && tflint) || echo "tflint not installed, skipped"

test: audit

plan:
	terraform -chdir=$(TF_DIR) plan -out=tfplan
	terraform -chdir=$(TF_DIR) show -json tfplan > $(TF_DIR)/tfplan.json
	conftest test --all-namespaces -p $(GOV)/policies/terraform $(TF_DIR)/tfplan.json

audit:
	$(GOV)/scripts/audit-repo.sh .
