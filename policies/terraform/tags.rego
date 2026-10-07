package terraform.tags

import rego.v1

required_tags := {"project", "env", "owner", "managed-by"}

# Taggable = the plan carries a "tags" attribute (null or map) for this resource.
taggable(rc) if {
	startswith(rc.type, "azurerm_")
	"tags" in object.keys(rc.change.after)
}

deny contains msg if {
	some rc in input.resource_changes
	"create" in rc.change.actions
	taggable(rc)
	tags := object.get(rc.change.after, "tags", null)
	given := object.get({"t": tags}, "t", {})
	have := {k | some k, _ in given}
	missing := required_tags - have
	count(missing) > 0
	msg := sprintf("TF-5: %s is missing tags: %v", [rc.address, missing])
}
