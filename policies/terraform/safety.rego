package terraform.safety

import rego.v1

allowed_regions := {"francecentral", "westeurope"}

stateful_types := {
	"azurerm_mssql_server",
	"azurerm_mssql_database",
	"azurerm_postgresql_flexible_server",
	"azurerm_key_vault",
	"azurerm_kubernetes_cluster",
	"azurerm_container_registry",
}

# TF-10: region allowlist.
deny contains msg if {
	some rc in input.resource_changes
	"create" in rc.change.actions
	loc := rc.change.after.location
	is_string(loc)
	not lower(replace(loc, " ", "")) in allowed_regions
	msg := sprintf("TF-10: %s uses region %q, allowed: %v", [rc.address, loc, allowed_regions])
}

# TF-12: no public network access on data services.
deny contains msg if {
	some rc in input.resource_changes
	"create" in rc.change.actions
	rc.type in stateful_types
	rc.change.after.public_network_access_enabled == true
	msg := sprintf("TF-12: %s enables public network access", [rc.address])
}

# TF-9: prevent_destroy cannot be read from plan JSON, so it is checked
# against configuration in scripts/check-prevent-destroy.sh.

# Destroying a stateful resource in a plan is always blocked here;
# a human must remove it from the plan via a reviewed PR.
deny contains msg if {
	some rc in input.resource_changes
	rc.type in stateful_types
	"delete" in rc.change.actions
	msg := sprintf("TF-9: plan destroys stateful resource %s", [rc.address])
}
