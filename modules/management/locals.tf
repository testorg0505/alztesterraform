# The following block of locals are used to avoid using
# empty object types in the code.
locals {
  empty_string = ""
  empty_list   = []
  empty_map    = {}
}

# Convert the input vars to locals, applying any required
# logic needed before they are used in the module.
# No vars should be referenced elsewhere in the module.
# NOTE: Need to catch error for resource_suffix when
# no value for subscription_id is provided.
locals {
  enabled                                      = var.enabled
  root_id                                      = var.root_id
  resource_type_names                          = var.resource_type_names
  subscription_id                              = coalesce(var.subscription_id, "00000000-0000-0000-0000-000000000000")
  settings                                     = var.settings
  location                                     = var.location
  tags                                         = var.tags
  resource_prefix                              = coalesce(var.resource_prefix, local.root_id)
  resource_suffix                              = length(var.resource_suffix) > 0 ? "-${var.resource_suffix}" : local.empty_string
  existing_resource_group_name                 = var.existing_resource_group_name
  existing_log_analytics_workspace_resource_id = var.existing_log_analytics_workspace_resource_id
  existing_automation_account_resource_id      = var.existing_automation_account_resource_id
  link_log_analytics_to_automation_account     = var.link_log_analytics_to_automation_account
  custom_settings                              = var.custom_settings_by_resource_type
  custom_azure_backup_geo_codes                = var.custom_azure_backup_geo_codes
  asc_export_resource_group_name               = coalesce(var.asc_export_resource_group_name, "${local.root_id}-asc-export")
}

# Extract individual custom settings blocks from
# the custom_settings_by_resource_type variable.
locals {
  custom_settings_rsg                       = try(local.custom_settings.azurerm_resource_group["management"], local.empty_map)
  custom_settings_la_workspace              = try(local.custom_settings.azurerm_log_analytics_workspace["management"], local.empty_map)
  custom_settings_virtual_network           = try(local.custom_settings.azurerm_virtual_network, local.empty_map)
  custom_settings_subnets                   = try(local.custom_settings.azurerm_subnet, local.empty_map)
  custom_settings_network_security_groups   = try(local.custom_settings.azurerm_network_security_group, local.empty_map)
  custom_settings_route_tables              = try(local.custom_settings.azurerm_route_table, local.empty_map)
  custom_settings_storage_account           = try(local.custom_settings.azurerm_storage_account["management"], local.empty_map)
  custom_settings_la_solution               = try(local.custom_settings.azurerm_log_analytics_solution["management"], local.empty_map)
  custom_settings_aa                        = try(local.custom_settings.azurerm_automation_account["management"], local.empty_map)
  custom_settings_la_linked_service         = try(local.custom_settings.azurerm_log_analytics_linked_service["management"], local.empty_map)
}

# Logic to determine whether specific resources
# should be created by this module
locals {
  deploy_monitoring_settings          = local.settings.log_analytics.enabled
  deploy_monitoring_for_vm            = local.deploy_monitoring_settings && local.settings.log_analytics.config.enable_monitoring_for_vm
  deploy_monitoring_for_vmss          = local.deploy_monitoring_settings && local.settings.log_analytics.config.enable_monitoring_for_vmss
  deploy_monitoring_resources         = local.enabled && local.deploy_monitoring_settings
  deploy_resource_group               = local.deploy_monitoring_resources && local.existing_resource_group_name == local.empty_string
  deploy_network                      = local.deploy_monitoring_resources && local.settings.spoke_networks != local.empty_list
  deploy_log_analytics_workspace      = local.deploy_monitoring_resources && local.existing_log_analytics_workspace_resource_id == local.empty_string
  deploy_log_analytics_linked_service = local.deploy_monitoring_resources && local.link_log_analytics_to_automation_account
  deploy_automation_account           = local.deploy_monitoring_resources && local.existing_automation_account_resource_id == local.empty_string
  deploy_azure_monitor_solutions = {
    AgentHealthAssessment       = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_agent_health_assessment
    AntiMalware                 = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_anti_malware
    ChangeTracking              = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_change_tracking
    Security                    = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_sentinel
    SecurityInsights            = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_sentinel
    ServiceMap                  = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_service_map
    SQLAssessment               = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_sql_assessment
    SQLVulnerabilityAssessment  = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_sql_vulnerability_assessment
    SQLAdvancedThreatProtection = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_sql_advanced_threat_detection
    Updates                     = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_updates
    VMInsights                  = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_vm_insights
    ContainerInsights           = local.deploy_monitoring_resources && local.settings.log_analytics.config.enable_solution_for_container_insights
  }
  deploy_security_settings                              = local.settings.security_center.enabled
  deploy_defender_for_apis                              = local.settings.security_center.config.enable_defender_for_apis
  deploy_defender_for_app_services                      = local.settings.security_center.config.enable_defender_for_app_services
  deploy_defender_for_arm                               = local.settings.security_center.config.enable_defender_for_arm
  deploy_defender_for_containers                        = local.settings.security_center.config.enable_defender_for_containers
  deploy_defender_for_cosmosdbs                         = local.settings.security_center.config.enable_defender_for_cosmosdbs
  deploy_defender_for_cspm                              = local.settings.security_center.config.enable_defender_for_cspm
  deploy_defender_for_dns                               = local.settings.security_center.config.enable_defender_for_dns
  deploy_defender_for_key_vault                         = local.settings.security_center.config.enable_defender_for_key_vault
  deploy_defender_for_oss_databases                     = local.settings.security_center.config.enable_defender_for_oss_databases
  deploy_defender_for_servers                           = local.settings.security_center.config.enable_defender_for_servers
  deploy_defender_for_servers_vulnerability_assessments = local.settings.security_center.config.enable_defender_for_servers_vulnerability_assessments
  deploy_defender_for_sql_servers                       = local.settings.security_center.config.enable_defender_for_sql_servers
  deploy_defender_for_sql_server_vms                    = local.settings.security_center.config.enable_defender_for_sql_server_vms
  deploy_defender_for_storage                           = local.settings.security_center.config.enable_defender_for_storage
}

# Logic to help keep code DRY
locals {
  spoke_networks = local.settings.spoke_networks
  # We generate the spoke_networks_by_identifier as a map
  # to ensure the user has provided unique values for
  # each spoke identifier If duplicates are found,
  # terraform will throw an error at this point.
  spoke_networks_by_identifier = {
    for spoke_network, configuration in local.spoke_networks :
    configuration.identifier => configuration
  }
  all_spoke_network_locations = [
    for spoke_network, configuration in local.spoke_networks :
    configuration.config.location
  ]
  spoke_network_locations = distinct(local.all_spoke_network_locations)
}

# Configuration settings for resource type:
#  - azurerm_resource_group
locals {
  # Determine the name of each Resource Group per scope and location
  network_resource_group_name = {
    for location in local.spoke_network_locations :
    "network_${location}" => "${local.resource_type_names.resource_group}-${lookup(local.custom_azure_backup_geo_codes, location, location)}-${local.resource_prefix}-network${local.resource_suffix}"
  }
  management_resource_group_name = {
    management = coalesce(
      local.existing_resource_group_name,
      "${local.resource_type_names.resource_group}-${lookup(local.custom_azure_backup_geo_codes, local.location, local.location)}-${local.resource_prefix}-management${local.resource_suffix}"
    )
    alerts     = "alertsRG"
  }
  resource_group_name = merge(local.network_resource_group_name, local.management_resource_group_name)
  resource_group_resource_id = {
    for scope, name in local.resource_group_name :
    scope => "/subscriptions/${local.subscription_id}/resourceGroups/${name}"
  }
  # Generate a map of settings for each Resource Group per scope and location
  azurerm_resource_group = {
    for scope, name in local.resource_group_name :
    scope => {
      # Resource logic attributes
      resource_id = "/subscriptions/${local.subscription_id}/resourceGroups/${name}"
      scope       = scope
      # Resource definition attributes
      name        = name
      location    = length(split("_", scope)) > 1 ? split("_", scope)[1] : local.location
      tags        = local.tags
    }
  }
}

# Configuration settings for resource type:
#  - azurerm_virtual_network
locals {
  virtual_network_name = {
    for identifier, spoke_network in local.spoke_networks_by_identifier :
    identifier =>
    try(local.custom_settings.azurerm_virtual_network[identifier].name,
    "${local.resource_type_names.virtual_network}-${lookup(local.custom_azure_backup_geo_codes, spoke_network.config.location, spoke_network.config.location)}-${local.resource_prefix}-${replace(spoke_network.config.address_space[0],"/","_")}${local.resource_suffix}")
  }
  virtual_network_resource_id_prefix = {
    for location in local.spoke_network_locations :
    location =>
    "${local.resource_group_resource_id["network_${location}"]}/providers/Microsoft.Network/virtualNetworks"
  }
  virtual_network_resource_id = {
    for identifier, spoke_network in local.spoke_networks_by_identifier :
    identifier =>
    "${local.virtual_network_resource_id_prefix[spoke_network.config.location]}/${local.virtual_network_name[identifier]}"
  }
  azurerm_virtual_network = [
    for identifier, spoke_network in local.spoke_networks_by_identifier :
    {
      # Resource logic attributes
      resource_id = local.virtual_network_resource_id[identifier]
      # Resource definition attributes
      name                 = local.virtual_network_name[identifier]
      resource_group_name  = local.resource_group_name["network_${spoke_network.config.location}"]
      address_space        = spoke_network.config.address_space
      location             = spoke_network.config.location
      bgp_community        = null
      dns_servers          = spoke_network.config.dns_servers
      tags                 = try(local.custom_settings_virtual_network[identifier].tags, local.tags)
      ddos_protection_plan = []
    }
  ]
}

# Configuration settings for resource type:
#  - azurerm_subnet
locals {
  network_security_group_resource_id_prefix = {
    for location in local.spoke_network_locations :
    location =>
    "${local.resource_group_resource_id["network_${location}"]}/providers/Microsoft.Network/networkSecurityGroups"
  }
  route_table_resource_id_prefix = {
    for location in local.spoke_network_locations :
    location =>
    "${local.resource_group_resource_id["network_${location}"]}/providers/Microsoft.Network/routeTables"
  }
  subnets_by_virtual_network = {
    for identifier, spoke_network in local.spoke_networks_by_identifier :
    local.virtual_network_resource_id[identifier] => concat(
      # Get customer specified subnets and add additional required attributes
      [
        for subnet in spoke_network.config.subnets : merge(
          subnet,
          {
            # Resource logic attributes
            resource_id                   = "${local.virtual_network_resource_id[identifier]}/subnets/${subnet.name}"
            location                      = spoke_network.config.location
            vnet_identifier               = identifier
            network_security_group_id     = "${local.network_security_group_resource_id_prefix[spoke_network.config.location]}/${try(local.custom_settings_network_security_groups[identifier][subnet.name].name, "${local.resource_type_names.network_security_group}-${lookup(local.custom_azure_backup_geo_codes, spoke_network.config.location, spoke_network.config.location)}-${local.resource_prefix}-${subnet.name}${local.resource_suffix}")}"
            route_table_id                = "${local.route_table_resource_id_prefix[spoke_network.config.location]}/${try(local.custom_settings_route_tables[identifier][subnet.name].name,"${local.resource_type_names.route_table}-${lookup(local.custom_azure_backup_geo_codes, spoke_network.config.location, spoke_network.config.location)}-${local.resource_prefix}-${subnet.name}${local.resource_suffix}")}"
            routes                        = coalesce(subnet.routes, local.empty_list)
            rules                         = coalesce(subnet.rules, local.empty_list)
            # Resource definition attributes
            name                                          = subnet.name
            resource_group_name                           = local.resource_group_name["network_${spoke_network.config.location}"]
            virtual_network_name                          = local.virtual_network_name[identifier]
            private_endpoint_network_policies     = try(local.custom_settings_subnets[identifier][subnet.name].private_endpoint_network_policies, "Disabled")
            private_link_service_network_policies_enabled = try(local.custom_settings_subnets[identifier][subnet.name].private_link_service_network_policies_enabled, false)
            service_endpoints                             = try(local.custom_settings_subnets[identifier][subnet.name].service_endpoints, subnet.service_endpoints)
            service_endpoint_policy_ids                   = try(local.custom_settings_subnets[identifier][subnet.name].service_endpoint_policy_ids, null)
            delegation                                    = try(local.custom_settings_subnets[identifier][subnet.name].delegation, subnet.delegations)
          }
        )
      ]
    )
  }
  azurerm_subnet = flatten([
    for subnets in local.subnets_by_virtual_network :
    subnets
  ])
}

# Configuration settings for resource type:
#  - azurerm_network_security_group
locals {
  azurerm_network_security_group = [
    for subnet in local.azurerm_subnet : {
      # Resource logic attributes
      resource_id   = subnet.network_security_group_id
      subnet_id     = subnet.resource_id
      # Resource definition attributes
      name                = try(local.custom_settings_network_security_groups[subnet.vnet_identifier][subnet.name].name, "${try(split("/", subnet.network_security_group_id)[8],"")}")
      resource_group_name = try(local.custom_settings_network_security_groups[subnet.vnet_identifier][subnet.name].resource_group_name, subnet.resource_group_name)
      location            = try(local.custom_settings_network_security_groups[subnet.vnet_identifier][subnet.name].location, subnet.location)
      tags                = try(local.custom_settings_network_security_groups[subnet.vnet_identifier][subnet.name].tags, local.tags)
      security_rule       = try(local.custom_settings_network_security_groups[subnet.vnet_identifier][subnet.name].security_rule, subnet.rules)
    }
  ]
}

# Configuration settings for resource type:
#  - azurerm_route_table
locals {
  azurerm_route_table = [
    for subnet in local.azurerm_subnet : {
      # Resource logic attributes
      resource_id   = subnet.route_table_id
      subnet_id     = subnet.resource_id
      # Resource definition attributes
      name                          = try(local.custom_settings_route_tables[subnet.vnet_identifier][subnet.name].name, "${try(split("/", subnet.route_table_id)[8],"")}")
      resource_group_name           = try(local.custom_settings_route_tables[subnet.vnet_identifier][subnet.name].resource_group_name, subnet.resource_group_name)
      location                      = try(local.custom_settings_route_tables[subnet.vnet_identifier][subnet.name].location, subnet.location)
      tags                          = try(local.custom_settings_route_tables[subnet.vnet_identifier][subnet.name].tags, local.tags)
      bgp_route_propagation_enabled = try(local.custom_settings_route_tables[subnet.vnet_identifier][subnet.name].bgp_route_propagation_enabled, subnet.bgp_route_propagation_enabled)
      route                         = try(local.custom_settings_route_tables[subnet.vnet_identifier][subnet.name].route, subnet.routes)
    }
  ]
}

# Configuration settings for resource type:
#  - azurerm_subnet_network_security_group_association
locals {
  azurerm_subnet_network_security_group_association = [
    for subnet in local.azurerm_subnet : {
      # Resource logic attributes
      network_security_group_id   = subnet.network_security_group_id
      subnet_id                   = subnet.resource_id
    }
  ]
}

# Configuration settings for resource type:
#  - azurerm_subnet_route_table_association
locals {
  azurerm_subnet_route_table_association = [
    for subnet in local.azurerm_subnet : {
      # Resource logic attributes
      route_table_id  = subnet.route_table_id
      subnet_id       = subnet.resource_id
    }
  ]
}

# Configuration settings for resource type:
#  - azurerm_virtual_network_peering
locals {
  virtual_network_peering_name = {
    for identifier, spoke_network in local.spoke_networks_by_identifier :
    identifier =>
    try(local.custom_settings.azurerm_virtual_network_peering[identifier].name,
    "peering-${try(split("/", spoke_network.config.hub_network_id)[2],"")}")
  }
  virtual_network_peering_resource_id_prefix = {
    for identifier, vnet_prefix in local.virtual_network_resource_id :
    identifier =>
    "${vnet_prefix}/virtualNetworkPeerings"
  }
  virtual_network_peering_resource_id = {
    for identifier, spoke_network in local.spoke_networks_by_identifier :
    identifier =>
    "${local.virtual_network_peering_resource_id_prefix[identifier]}/${local.virtual_network_peering_name[identifier]}"
  }
  azurerm_virtual_network_peering = [
    for identifier, spoke_network in local.spoke_networks_by_identifier :
    {
      # Resource logic attributes
      resource_id = local.virtual_network_peering_resource_id[identifier]
      # Resource definition attributes
      name                        = local.virtual_network_peering_name[identifier]
      virtual_network_name        = local.virtual_network_name[identifier]
      resource_group_name         = local.resource_group_name["network_${spoke_network.config.location}"]
      remote_virtual_network_id   = try(spoke_network.config.hub_network_id, "")
      # Optional definition attributes
      allow_virtual_network_access  = try(spoke_network.config.allow_virtual_network_access, true)
      allow_forwarded_traffic       = try(spoke_network.config.allow_forwarded_traffic, true)
      allow_gateway_transit         = false
      use_remote_gateways           = try(spoke_network.config.use_remote_gateways, false)
    }
  ]
}

# Configuration settings for resource type:
#  - azurerm_storage_account
locals {
  storage_account_resource_id = "${local.resource_group_resource_id.management}/providers/Microsoft.Storage/storageAccounts/${local.azurerm_storage_account.name}"
  azurerm_storage_account = {
    name                               = lookup(local.custom_settings_storage_account, "name", "${local.resource_type_names.storage_account}${local.resource_type_names.organization}${lookup(local.custom_azure_backup_geo_codes, local.location, local.location)}platmgmt01${local.resource_suffix}")
    resource_group_name                = lookup(local.custom_settings_storage_account, "resource_group_name", local.resource_group_name.management)
    location                           = lookup(local.custom_settings_storage_account, "location", local.location)
    account_tier                       = lookup(local.custom_settings_storage_account, "account_tier", "Standard")
    account_replication_type           = lookup(local.custom_settings_storage_account, "account_replication_type", "LRS")
    tags                               = lookup(local.custom_settings_storage_account, "tags", local.tags)
  }
}

# Configuration settings for resource type:
#  - azurerm_log_analytics_workspace
locals {
  log_analytics_workspace_resource_id = coalesce(
    local.existing_log_analytics_workspace_resource_id,
    "${local.resource_group_resource_id.management}/providers/Microsoft.OperationalInsights/workspaces/${local.azurerm_log_analytics_workspace.name}"
  )
  azurerm_log_analytics_workspace = {
    name                               = lookup(local.custom_settings_la_workspace, "name", "${local.resource_type_names.log_analytics}-${lookup(local.custom_azure_backup_geo_codes, local.location, local.location)}-${local.resource_prefix}-01${local.resource_suffix}")
    resource_group_name                = lookup(local.custom_settings_la_workspace, "resource_group_name", local.resource_group_name.management)
    location                           = lookup(local.custom_settings_la_workspace, "location", local.location)
    allow_resource_only_permissions    = lookup(local.custom_settings_la_workspace, "allow_resource_only_permissions", true) # Available only in v3.36.0 onwards
    sku                                = lookup(local.custom_settings_la_workspace, "sku", "PerGB2018")
    retention_in_days                  = lookup(local.custom_settings_la_workspace, "retention_in_days", local.settings.log_analytics.config.retention_in_days)
    daily_quota_gb                     = lookup(local.custom_settings_la_workspace, "daily_quota_gb", null)
    cmk_for_query_forced               = lookup(local.custom_settings_la_workspace, "cmk_for_query_forced", null)
    internet_ingestion_enabled         = lookup(local.custom_settings_la_workspace, "internet_ingestion_enabled", true)
    internet_query_enabled             = lookup(local.custom_settings_la_workspace, "internet_query_enabled", true)
    reservation_capacity_in_gb_per_day = lookup(local.custom_settings_la_workspace, "reservation_capacity_in_gb_per_day", null)
    tags                               = lookup(local.custom_settings_la_workspace, "tags", local.tags)
  }
}

# Configuration settings for resource type:
#  - azurerm_log_analytics_solution
locals {
  log_analytics_solution_resource_id = {
    for resource in local.azurerm_log_analytics_solution :
    resource.solution_name => "${local.resource_group_resource_id.management}/providers/Microsoft.OperationsManagement/solutions/${resource.solution_name}(${local.azurerm_log_analytics_workspace.name})"
  }
  azurerm_log_analytics_solution = [
    for solution_name, solution_enabled in local.deploy_azure_monitor_solutions :
    {
      solution_name         = solution_name
      resource_group_name   = lookup(local.custom_settings_la_solution, "resource_group_name", local.resource_group_name.management)
      location              = lookup(local.custom_settings_la_solution, "location", local.location)
      workspace_resource_id = local.log_analytics_workspace_resource_id
      workspace_name        = basename(local.log_analytics_workspace_resource_id)
      tags                  = lookup(local.custom_settings_la_solution, "tags", local.tags)
      plan = {
        publisher = "Microsoft"
        product   = "OMSGallery/${solution_name}"
      }
    }
    if solution_enabled
  ]
}

# Configuration settings for resource type:
#  - azurerm_automation_account
locals {
  automation_account_resource_id = coalesce(
    local.existing_automation_account_resource_id,
    "${local.resource_group_resource_id.management}/providers/Microsoft.Automation/automationAccounts/${local.azurerm_automation_account.name}"
  )
  # As per issue #449, some automation accounts should be created in a different region to the log analytics workspace
  # The automation_account_location_map local is used to track these
  automation_account_location_map = {
    eastus  = "eastus2"
    eastus2 = "eastus"
  }
  automation_account_location = coalesce(
    lookup(local.custom_settings_aa, "location", null),
    lookup(local.automation_account_location_map, local.location, local.location)
  )
  azurerm_automation_account = {
    name                          = lookup(local.custom_settings_aa, "name", "${local.resource_type_names.azure_automation}-${lookup(local.custom_azure_backup_geo_codes, local.location, local.location)}-${local.resource_prefix}-01${local.resource_suffix}")
    resource_group_name           = lookup(local.custom_settings_aa, "resource_group_name", local.resource_group_name.management)
    location                      = lookup(local.custom_settings_aa, "location", local.automation_account_location)
    sku_name                      = lookup(local.custom_settings_aa, "sku_name", "Basic")
    public_network_access_enabled = lookup(local.custom_settings_aa, "public_network_access_enabled", true)
    local_authentication_enabled  = lookup(local.custom_settings_aa, "local_authentication_enabled", true)
    identity                      = lookup(local.custom_settings_aa, "identity", local.empty_list)
    encryption                    = lookup(local.custom_settings_aa, "encryption", local.empty_list)
    tags                          = lookup(local.custom_settings_aa, "tags", local.tags)
  }
}

# Configuration settings for resource type:
#  - azurerm_log_analytics_linked_service
locals {
  log_analytics_linked_service_resource_id = "${local.log_analytics_workspace_resource_id}/linkedServices/Automation"
  azurerm_log_analytics_linked_service = {
    resource_group_name = lookup(local.custom_settings_la_linked_service, "resource_group_name", local.resource_group_name.management)
    workspace_id        = lookup(local.custom_settings_la_linked_service, "workspace_id", local.log_analytics_workspace_resource_id)
    read_access_id      = lookup(local.custom_settings_la_linked_service, "read_access_id", local.automation_account_resource_id) # This should be used for linking to an Automation Account resource.
    write_access_id     = null                                                                                                    # DO NOT USE. This should be used for linking to a Log Analytics Cluster resource
  }
}

locals{
  log_analytics_linked_storage_account_resource_id = "${local.log_analytics_workspace_resource_id}/linkedStorageAccounts/CustomLogs"
  azurerm_log_analytics_linked_storage_account = {
    data_source_type      = "CustomLogs"
    resource_group_name   = lookup(local.custom_settings_la_linked_service, "resource_group_name", local.resource_group_name.management)
    workspace_resource_id = lookup(local.custom_settings_la_linked_service, "workspace_id", local.log_analytics_workspace_resource_id)
    storage_account_ids   = [local.storage_account_resource_id]
  }
}

# Configuration settings for the action groups:
# - azurerm_monitor_action_group
locals {
  azurerm_monitor_action_group = {

    resource_id            = "${local.resource_group_resource_id["management"]}/providers/Microsoft.Insights/actiongroups/${local.settings.action_group_name}"
    name                   = "${local.settings.action_group_name}"
    resource_group_name    = local.resource_group_name["management"]
    action_group_shortname = local.settings.action_group_shortname
    tags                   = local.tags
    email_receiver         = {
      name = "Default"
      email_address = local.settings.contact_email
    }
  }
}

# Archetype configuration overrides
locals {
  archetype_config_overrides = {
    (local.root_id) = {
      parameters = {
        Deploy-MDFC-Config = {
          emailSecurityContact                        = local.settings.security_center.config.email_security_contact
          logAnalytics                                = local.log_analytics_workspace_resource_id
          ascExportResourceGroupName                  = local.asc_export_resource_group_name
          ascExportResourceGroupLocation              = local.location
          enableAscForApis                            = local.deploy_defender_for_apis ? "DeployIfNotExists" : "Disabled"
          enableAscForAppServices                     = local.deploy_defender_for_app_services ? "DeployIfNotExists" : "Disabled"
          enableAscForArm                             = local.deploy_defender_for_arm ? "DeployIfNotExists" : "Disabled"
          enableAscForContainers                      = local.deploy_defender_for_containers ? "DeployIfNotExists" : "Disabled"
          enableAscForCosmosDbs                       = local.deploy_defender_for_cosmosdbs ? "DeployIfNotExists" : "Disabled"
          enableAscForCspm                            = local.deploy_defender_for_cspm ? "DeployIfNotExists" : "Disabled"
          enableAscForDns                             = local.deploy_defender_for_dns ? "DeployIfNotExists" : "Disabled"
          enableAscForKeyVault                        = local.deploy_defender_for_key_vault ? "DeployIfNotExists" : "Disabled"
          enableAscForOssDb                           = local.deploy_defender_for_oss_databases ? "DeployIfNotExists" : "Disabled"
          enableAscForServers                         = local.deploy_defender_for_servers ? "DeployIfNotExists" : "Disabled"
          enableAscForServersVulnerabilityAssessments = local.deploy_defender_for_servers_vulnerability_assessments ? "DeployIfNotExists" : "Disabled"
          enableAscForSql                             = local.deploy_defender_for_sql_servers ? "DeployIfNotExists" : "Disabled"
          enableAscForSqlOnVm                         = local.deploy_defender_for_sql_server_vms ? "DeployIfNotExists" : "Disabled"
          enableAscForStorage                         = local.deploy_defender_for_storage ? "DeployIfNotExists" : "Disabled"
        }
        Deploy-VM-Monitoring = {
          logAnalytics_1 = local.log_analytics_workspace_resource_id
        }
        Deploy-VMSS-Monitoring = {
          logAnalytics_1 = local.log_analytics_workspace_resource_id
        }
        Deploy-AzActivity-Log = {
          logAnalytics = local.log_analytics_workspace_resource_id
        }
        Deploy-Resource-Diag = {
          logAnalytics = local.log_analytics_workspace_resource_id
        }
        Deploy-Flow-Logs = {
          storageId = local.storage_account_resource_id
        }
        Deploy-ServiceHealth ={
          actionGroupId = local.azurerm_monitor_action_group.resource_id
        }
      }
      enforcement_mode = {
        Deploy-MDFC-Config     = local.deploy_security_settings
        Deploy-VM-Monitoring   = local.deploy_monitoring_for_vm
        Deploy-VMSS-Monitoring = local.deploy_monitoring_for_vmss
      }
    }
    "${local.root_id}-landingzones" = {
      parameters = {
        Deploy-AzSqlDb-Auditing = {
          logAnalyticsWorkspaceId = local.log_analytics_workspace_resource_id
        }
      }
      enforcement_mode = {}
    }
    "${local.root_id}-platform-management" = {
      parameters = {
        Deploy-Log-Analytics = {
          automationAccountName = local.azurerm_automation_account.name
          automationRegion      = local.azurerm_automation_account.location
          rgName                = local.resource_group_name.management
          workspaceName         = local.azurerm_log_analytics_workspace.name
          workspaceRegion       = local.azurerm_log_analytics_workspace.location
          # Need to ensure dataRetention gets handled as a string
          dataRetention = tostring(local.azurerm_log_analytics_workspace.retention_in_days)
          # Need to ensure sku value is set to lowercase only when "PerGB2018" specified
          # Evaluating in lower() to ensure the correct error is surfaced on the resource if invalid casing is used
          sku = lower(local.azurerm_log_analytics_workspace.sku) == "pergb2018" ? lower(local.azurerm_log_analytics_workspace.sku) : local.azurerm_log_analytics_workspace.sku
        }
      }
      enforcement_mode = {
        Deploy-Log-Analytics = false
      }
    }
  }
}

# Template file variable outputs
locals {
  template_file_variables = {
    log_analytics_workspace_resource_id = local.log_analytics_workspace_resource_id
    log_analytics_workspace_name        = local.azurerm_log_analytics_workspace.name
    log_analytics_workspace_location    = local.azurerm_log_analytics_workspace.location
    automation_account_resource_id      = local.automation_account_resource_id
    automation_account_name             = local.azurerm_automation_account.name
    automation_account_location         = local.azurerm_automation_account.location
    management_location                 = local.location
    management_resource_group_name      = local.resource_group_name.management
    data_retention                      = tostring(local.azurerm_log_analytics_workspace.retention_in_days)
  }
}

# Generate the configuration output object for the management module
locals {
  module_output = {
    azurerm_resource_group = [
      for resource in local.azurerm_resource_group :
      {
        resource_id   = resource.resource_id
        resource_name = resource.name
        template = {
          for key, value in resource :
          key => value
          if local.deploy_resource_group &&
          key != "resource_id" &&
          key != "managed_by_module"
        }
        managed_by_module = local.deploy_resource_group
      }
    ]
    azurerm_virtual_network = [
      for resource in local.azurerm_virtual_network :
      {
        resource_id   = resource.resource_id
        resource_name = resource.name
        template = {
          for key, value in resource :
          key => value
          if local.deploy_network &&
          key != "resource_id" &&
          key != "managed_by_module"
        }
        managed_by_module = local.deploy_network
      }
    ]
    azurerm_subnet = [
      for resource in local.azurerm_subnet :
      {
        resource_id   = resource.resource_id
        resource_name = resource.name
        template = {
          for key, value in resource :
          key => value
          if local.deploy_network &&
          key != "resource_id" &&
          key != "managed_by_module" &&
          key != "location" &&
          key != "network_security_group_id" &&
          key != "route_table_id" &&
          key != "vnet_identifier" &&
          key != "routes" &&
          key != "rules"
        }
        managed_by_module = local.deploy_network
      }
    ]
    azurerm_network_security_group = [
      for resource in local.azurerm_network_security_group :
      {
        resource_id   = resource.resource_id
        resource_name = basename(resource.resource_id)
        template = {
          for key, value in resource :
          key => value
          if local.deploy_network &&
          key != "resource_id" &&
          key != "managed_by_module"
        }
        managed_by_module = local.deploy_network
      }
    ]
    azurerm_route_table = [
      for resource in local.azurerm_route_table :
      {
        resource_id   = resource.resource_id
        resource_name = basename(resource.resource_id)
        template = {
          for key, value in resource :
          key => value
          if local.deploy_network &&
          key != "resource_id" &&
          key != "managed_by_module"
        }
        managed_by_module = local.deploy_network
      }
    ]
    azurerm_subnet_network_security_group_association = [
      for resource in local.azurerm_subnet_network_security_group_association :
      {
        resource_id   = resource.subnet_id
        template = {
          for key, value in resource :
          key => value
          if local.deploy_network &&
          key != "resource_id" &&
          key != "managed_by_module"
        }
        managed_by_module = local.deploy_network
      }
    ]
    azurerm_subnet_route_table_association = [
      for resource in local.azurerm_subnet_route_table_association :
      {
        resource_id   = resource.subnet_id
        template = {
          for key, value in resource :
          key => value
          if local.deploy_network &&
          key != "resource_id" &&
          key != "managed_by_module"
        }
        managed_by_module = local.deploy_network
      }
    ]
    azurerm_virtual_network_peering = [
      for resource in local.azurerm_virtual_network_peering :
      {
        resource_id   = resource.resource_id
        resource_name = resource.name
        template = {
          for key, value in resource :
          key => value
          if local.deploy_network &&
          key != "resource_id" &&
          key != "managed_by_module"
        }
        managed_by_module = local.deploy_network
      }
    ]
    azurerm_storage_account = [
      {
        resource_id   = local.storage_account_resource_id
        resource_name = basename(local.storage_account_resource_id)
        template = {
          for key, value in local.azurerm_storage_account :
          key => value
          if local.deploy_log_analytics_workspace
        }
        managed_by_module = local.deploy_log_analytics_workspace
      },
    ]
    azurerm_log_analytics_workspace = [
      {
        resource_id   = local.log_analytics_workspace_resource_id
        resource_name = basename(local.log_analytics_workspace_resource_id)
        template = {
          for key, value in local.azurerm_log_analytics_workspace :
          key => value
          if local.deploy_log_analytics_workspace
        }
        managed_by_module = local.deploy_log_analytics_workspace
      },
    ]
    azurerm_log_analytics_solution = [
      for resource in local.azurerm_log_analytics_solution :
      {
        resource_id       = local.log_analytics_solution_resource_id[resource.solution_name]
        resource_name     = basename(local.log_analytics_solution_resource_id[resource.solution_name])
        template          = resource
        managed_by_module = true
      }
    ]
    azurerm_automation_account = [
      {
        resource_id   = local.automation_account_resource_id
        resource_name = basename(local.automation_account_resource_id)
        template = {
          for key, value in local.azurerm_automation_account :
          key => value
          if local.deploy_automation_account
        }
        managed_by_module = local.deploy_automation_account
      },
    ]
    azurerm_log_analytics_linked_service = [
      {
        resource_id   = local.log_analytics_linked_service_resource_id
        resource_name = basename(local.log_analytics_linked_service_resource_id)
        template = {
          for key, value in local.azurerm_log_analytics_linked_service :
          key => value
          if local.deploy_log_analytics_linked_service
        }
        managed_by_module = local.deploy_log_analytics_linked_service
      },
    ]
    azurerm_log_analytics_linked_storage_account = [
      {
        resource_id   = local.log_analytics_linked_storage_account_resource_id
        resource_name = basename(local.log_analytics_linked_storage_account_resource_id)
        template = {
          for key, value in local.azurerm_log_analytics_linked_storage_account :
          key => value
          if local.deploy_log_analytics_linked_service
        }
        managed_by_module = local.deploy_log_analytics_linked_service
      },
    ]
    azurerm_monitor_action_group = [
      {
        resource_name = local.azurerm_monitor_action_group.name
        template = {
          for key, value in local.azurerm_monitor_action_group :
          key => value
          if local.deploy_log_analytics_workspace
        }
        managed_by_module = local.deploy_log_analytics_workspace
      },
    ]
    archetype_config_overrides = local.archetype_config_overrides
    template_file_variables    = local.template_file_variables
  }
}
