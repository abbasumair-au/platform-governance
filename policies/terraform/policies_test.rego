package terraform

import rego.v1

import data.terraform.naming
import data.terraform.safety
import data.terraform.tags

good_tags := {"project": "lab", "env": "dev", "owner": "umair", "managed-by": "terraform"}

rc(type, name, after) := {"address": sprintf("%s.x", [type]), "type": type, "change": {"actions": ["create"], "after": object.union(after, {"name": name})}}

test_tags_missing_denied if {
	r := rc("azurerm_resource_group", "rg-lab-dev", {"location": "francecentral", "tags": {"project": "lab"}})
	count(tags.deny) == 1 with input as {"resource_changes": [r]}
}

test_tags_null_denied if {
	r := rc("azurerm_resource_group", "rg-lab-dev", {"location": "francecentral", "tags": null})
	count(tags.deny) == 1 with input as {"resource_changes": [r]}
}

test_tags_ok if {
	r := rc("azurerm_resource_group", "rg-lab-dev", {"location": "francecentral", "tags": good_tags})
	count(tags.deny) == 0 with input as {"resource_changes": [r]}
}

test_untaggable_resource_ignored if {
	r := rc("azurerm_role_assignment", "x", {})
	count(tags.deny) == 0 with input as {"resource_changes": [r]}
}

test_naming_bad_prefix_denied if {
	r := rc("azurerm_resource_group", "mygroup", {"location": "francecentral"})
	count(naming.deny) == 1 with input as {"resource_changes": [r]}
}

test_naming_ok if {
	r := rc("azurerm_kubernetes_cluster", "aks-lab-dev", {})
	count(naming.deny) == 0 with input as {"resource_changes": [r]}
}

test_acr_hyphen_denied if {
	r := rc("azurerm_container_registry", "my-acr", {})
	count(naming.deny) == 1 with input as {"resource_changes": [r]}
}

test_region_denied if {
	r := rc("azurerm_resource_group", "rg-lab-dev", {"location": "eastus"})
	count(safety.deny) == 1 with input as {"resource_changes": [r]}
}

test_region_display_name_ok if {
	r := rc("azurerm_resource_group", "rg-lab-dev", {"location": "West Europe"})
	count(safety.deny) == 0 with input as {"resource_changes": [r]}
}

test_public_access_denied if {
	r := rc("azurerm_key_vault", "kv-lab", {"location": "francecentral", "public_network_access_enabled": true})
	count(safety.deny) == 1 with input as {"resource_changes": [r]}
}

test_stateful_delete_denied if {
	r := {"address": "azurerm_key_vault.x", "type": "azurerm_key_vault", "change": {"actions": ["delete"], "after": null}}
	count(safety.deny) == 1 with input as {"resource_changes": [r]}
}
