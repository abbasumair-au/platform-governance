package terraform.naming

import rego.v1

# CAF abbreviation required as name prefix (TF-4).
prefixes := {
	"azurerm_resource_group": "rg-",
	"azurerm_virtual_network": "vnet-",
	"azurerm_subnet": "snet-",
	"azurerm_kubernetes_cluster": "aks-",
	"azurerm_network_security_group": "nsg-",
	"azurerm_log_analytics_workspace": "log-",
	"azurerm_user_assigned_identity": "id-",
	"azurerm_mssql_server": "sql-",
	"azurerm_postgresql_flexible_server": "psql-",
}

deny contains msg if {
	some rc in input.resource_changes
	"create" in rc.change.actions
	prefix := prefixes[rc.type]
	name := rc.change.after.name
	is_string(name)
	not startswith(name, prefix)
	msg := sprintf("TF-4: %s name %q must start with %q", [rc.address, name, prefix])
}

# Globally unique names: no hyphens allowed on ACR and storage accounts.
deny contains msg if {
	some rc in input.resource_changes
	"create" in rc.change.actions
	rc.type in {"azurerm_container_registry", "azurerm_storage_account"}
	name := rc.change.after.name
	is_string(name)
	contains(name, "-")
	msg := sprintf("TF-4: %s name %q must not contain hyphens", [rc.address, name])
}
