# The following block of locals are used to avoid using
# empty object types in the code
locals {
  empty_list   = []
  empty_map    = tomap({})
  empty_string = ""
}

# The following locals are used to convert provided input
# variables to locals before use elsewhere in the module
locals {
  root_id                          = var.root_id
  tenant_id                        = var.tenant_id
  root_name                        = var.root_name
  root_parent_id                   = var.root_parent_id
  resource_type_names              = var.resource_type_names
  deploy_core_landing_zones        = var.deploy_core_landing_zones
  deploy_corp_landing_zones        = var.deploy_corp_landing_zones
  deploy_online_landing_zones      = var.deploy_online_landing_zones
  deploy_sap_landing_zones         = var.deploy_sap_landing_zones
  deploy_demo_landing_zones        = var.deploy_demo_landing_zones
  deploy_management_resources      = var.deploy_management_resources
  deploy_identity_resources        = var.deploy_identity_resources
  deploy_connectivity_resources    = var.deploy_connectivity_resources
  deploy_landingzones_resources    = var.deploy_landingzones_resources
  deploy_diagnostics_for_mg        = var.deploy_diagnostics_for_mg
  configure_management_resources   = var.configure_management_resources
  configure_identity_resources     = var.configure_identity_resources
  configure_connectivity_resources = var.configure_connectivity_resources
  configure_landingzones_resources = var.configure_landingzones_resources
  archetype_config_overrides       = var.archetype_config_overrides
  subscription_id_overrides        = var.subscription_id_overrides
  subscription_id_connectivity     = var.subscription_id_connectivity
  subscription_id_identity         = var.subscription_id_identity
  subscription_id_management       = var.subscription_id_management
  subscription_id_landingzones     = var.subscription_id_landingzones
  custom_landing_zones             = var.custom_landing_zones
  custom_policy_roles              = var.custom_policy_roles
  library_path                     = var.library_path
  template_file_variables = merge(
    var.template_file_variables,
    module.connectivity_resources.configuration.template_file_variables,
    module.identity_resources.configuration.template_file_variables,
    module.management_resources.configuration.template_file_variables,
    module.landingzones_resources.configuration.template_file_variables,
  )
  default_location                = var.default_location
  default_tags                    = var.default_tags
  disable_base_module_tags        = var.disable_base_module_tags
  disable_telemetry               = var.disable_telemetry
  strict_subscription_association = var.strict_subscription_association
}

# The following locals are used to ensure non-null values
# are assigned to each of the corresponding inputs for
# correct processing in `lookup()` functions.
#
# We also need to ensure that each `???_resources_advanced`
# local is handled as an `object()` rather than `map()` to
# prevent `lookup()` errors when only partially specified
# with attributes of a single type.
#
# This is achieved by merging an `object()` with multiple
# types (`create_object`) to the input from `advanced`.
#
# For more information about this error, see:
# https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/issues/227#issuecomment-1097623677
locals {
  enforcement_mode_default = {
    enforcement_mode = {}
  }
  create_object = {
    # Technically only needs two object types to work.
    add_bool   = true
    add_string = local.empty_string
    add_list   = local.empty_list
    add_map    = local.empty_map
    add_null   = null
  }
  connectivity_resources_advanced = merge(
    local.create_object,
    coalesce(local.configure_connectivity_resources.advanced, local.empty_map)
  )
  management_resources_advanced = merge(
    local.create_object,
    coalesce(local.configure_management_resources.advanced, local.empty_map)
  )
  identity_resources_advanced = merge(
    local.create_object,
    coalesce(local.configure_identity_resources.advanced, local.empty_map)
  )
  landingzones_resources_advanced = merge(
    local.create_object,
    coalesce(local.configure_landingzones_resources.advanced, local.empty_map)
  )
  parameter_map_default = {
    parameters = local.empty_map
  }
}

# The following locals are used to define a set of module
# tags applied to all resources unless disabled by the
# input variable "disable_module_tags" and prepare the
# tag blocks for each sub-module
locals {
  base_module_tags = {}
  connectivity_resources_tags = merge(
    local.disable_base_module_tags ? local.empty_map : local.base_module_tags,
    local.default_tags,
    local.configure_connectivity_resources.tags,
  )
  management_resources_tags = merge(
    local.disable_base_module_tags ? local.empty_map : local.base_module_tags,
    local.default_tags,
    local.configure_management_resources.tags,
  )
  identity_resources_tags = merge(
    local.disable_base_module_tags ? local.empty_map : local.base_module_tags,
    local.default_tags,
    local.configure_identity_resources.tags,
  )
  landingzones_resources_tags = merge(
    local.disable_base_module_tags ? local.empty_map : local.base_module_tags,
    local.default_tags,
    local.configure_landingzones_resources.tags,
  )
}

# The following locals are used to define base Azure
# provider paths and resource types
locals {
  provider_path = {
    management_groups = "/providers/Microsoft.Management/managementGroups/"
    role_assignment   = "/providers/Microsoft.Authorization/roleAssignments/"
  }
  resource_types = {
    policy_definition     = "Microsoft.Authorization/policyDefinitions"
    policy_set_definition = "Microsoft.Authorization/policySetDefinitions"
  }
}

# The following locals are used to define RegEx
# patterns used within this module
locals {
  # The following regex is designed to consistently
  # split a resource_id into the following capture
  # groups, regardless of resource type:
  # [0] Resource scope, type substring (e.g. "/providers/Microsoft.Management/managementGroups/")
  # [1] Resource scope, name substring (e.g. "group1")
  # [2] Resource, type substring (e.g. "/providers/Microsoft.Authorization/policyAssignments/")
  # [3] Resource, name substring (e.g. "assignment1")
  regex_split_resource_id         = "(?i)((?:/[^/]+){0,8}/)?([^/]+)?((?:/[^/]+){3}/)([^/]+)$"
  regex_scope_is_management_group = "(?i)(/providers/Microsoft.Management/managementGroups/)([^/]+)$"
  # regex_scope_is_subscription     = "(?i)(/subscriptions/)([^/]+)$"
  # regex_scope_is_resource_group   = "(?i)(/subscriptions/[^/]+/resourceGroups/)([^/]+)$"
  # regex_scope_is_resource         = "(?i)(/subscriptions/[^/]+/resourceGroups(?:/[^/]+){4}/)([^/]+)$"
}

# The following locals are used to control time_sleep
# delays between resources to reduce transient errors
# relating to replication delays in Azure
locals {
  create_duration_delay = {
    after_azurerm_management_group      = var.create_duration_delay["azurerm_management_group"]
    after_azurerm_policy_assignment     = var.create_duration_delay["azurerm_policy_assignment"]
    after_azurerm_policy_definition     = var.create_duration_delay["azurerm_policy_definition"]
    after_azurerm_policy_set_definition = var.create_duration_delay["azurerm_policy_set_definition"]
    after_azurerm_role_assignment       = var.create_duration_delay["azurerm_role_assignment"]
    after_azurerm_role_definition       = var.create_duration_delay["azurerm_role_definition"]
  }
  destroy_duration_delay = {
    after_azurerm_management_group      = var.destroy_duration_delay["azurerm_management_group"]
    after_azurerm_policy_assignment     = var.destroy_duration_delay["azurerm_policy_assignment"]
    after_azurerm_policy_definition     = var.destroy_duration_delay["azurerm_policy_definition"]
    after_azurerm_policy_set_definition = var.destroy_duration_delay["azurerm_policy_set_definition"]
    after_azurerm_role_assignment       = var.destroy_duration_delay["azurerm_role_assignment"]
    after_azurerm_role_definition       = var.destroy_duration_delay["azurerm_role_definition"]
  }
}

# The follow locals are used to control non-compliance messages
locals {
  policy_non_compliance_message_enabled                   = var.policy_non_compliance_message_enabled
  policy_non_compliance_message_not_supported_definitions = var.policy_non_compliance_message_not_supported_definitions
  policy_non_compliance_message_default_enabled           = var.policy_non_compliance_message_default_enabled
  policy_non_compliance_message_default                   = var.policy_non_compliance_message_default
  policy_non_compliance_message_enforcement_placeholder   = var.policy_non_compliance_message_enforcement_placeholder
  policy_non_compliance_message_enforced_replacement      = var.policy_non_compliance_message_enforced_replacement
  policy_non_compliance_message_not_enforced_replacement  = var.policy_non_compliance_message_not_enforced_replacement
}
