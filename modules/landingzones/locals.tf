# The following block of locals are used to avoid using
# empty object types in the code.
locals {
  empty_list   = []
  empty_map    = {}
  empty_string = ""
}

# Convert the input vars to locals, applying any required
# logic needed before they are used in the module.
# No vars should be referenced elsewhere in the module.
# NOTE: Need to catch error for resource_suffix when
# no value for subscription_id is provided.
locals {
  enabled                       = var.enabled
  root_id                       = var.root_id
  tenant_id                     = var.tenant_id
  resource_type_names           = var.resource_type_names
  subscription_id               = coalesce(var.subscription_id, "00000000-0000-0000-0000-000000000000")
  settings                      = var.settings
  location                      = var.location
  tags                          = var.tags
  resource_prefix               = coalesce(var.resource_prefix, local.root_id)
  resource_suffix               = var.resource_suffix != local.empty_string ? "-${var.resource_suffix}" : local.empty_string
  custom_azure_backup_geo_codes = var.custom_azure_backup_geo_codes
  custom_settings               = var.custom_settings_by_resource_type
}

# Extract individual custom settings blocks from
# the custom_settings_by_resource_type variable.
locals {
  custom_settings_rsg                     = try(local.custom_settings.azurerm_resource_group["landingzones"], local.empty_map)
  custom_settings_virtual_network         = try(local.custom_settings.azurerm_virtual_network["landingzones"], local.empty_map)
  custom_settings_subnets                 = try(local.custom_settings.azurerm_subnet["landingzones"], local.empty_map)
  custom_settings_network_security_groups = try(local.custom_settings.azurerm_network_security_group["landingzones"], local.empty_map)
  custom_settings_route_tables            = try(local.custom_settings.azurerm_route_table["landingzones"], local.empty_map)
}

# Logic to determine whether specific resources
# should be created by this module
locals {
  deploy_landingzones                      = local.enabled && local.settings.landingzones.enabled
  deploy_network                           = local.deploy_landingzones && local.settings.spoke_networks != local.empty_list
}

# Template file variable outputs
locals {
  template_file_variables = local.empty_map
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
  monitoring_resource_group_name = {
    monitoring = "${local.resource_type_names.resource_group}-${lookup(local.custom_azure_backup_geo_codes, local.location, local.location)}-${local.resource_prefix}-monitoring${local.resource_suffix}"
  }
  resource_group_name = merge(local.network_resource_group_name, local.monitoring_resource_group_name)
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
      location    = local.location
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

locals {
  azurerm_role_assignment = [
    for resource in local.settings.rbac :
    {
      scope                            = "/subscriptions/${local.subscription_id}"
      role_definition_id               = resource.role_definition_id
      principal_id                     = resource.principal_id
      skip_service_principal_aad_check = false
    }
  ]
}

# Configuration settings for the action groups:
# - azurerm_monitor_action_group
locals {
  azurerm_monitor_action_group = {
    resource_id            = "${local.resource_group_resource_id["monitoring"]}/providers/Microsoft.Insights/actiongroups/${local.settings.landingzones.config.action_group_name}"
    name                   = local.settings.landingzones.config.action_group_name
    resource_group_name    = local.resource_group_name["monitoring"]
    action_group_shortname = local.settings.landingzones.config.action_group_shortname
    tags                   = local.tags
    email_receiver         = {
      name          = "Default"
      email_address = local.settings.landingzones.config.contact_email
    }
  }
}

# Configuration settings for the budget:
# - azurerm_consumption_budget_subscription
locals {
  azurerm_consumption_budget_subscription = {
    name                 = "${local.settings.landingzones.config.subscription_name}-budget"
    subscription_id      = "/subscriptions/${local.subscription_id}"
    amount               = local.settings.landingzones.config.amount
    start_date           = local.settings.landingzones.config.start_date
    end_date             = local.settings.landingzones.config.end_date
    enable_notifications = local.settings.landingzones.config.enable_notifications
    threshold            = local.settings.landingzones.config.threshold
    operator             = local.settings.landingzones.config.operator
    contact_groups       = [local.azurerm_monitor_action_group.resource_id]
  }
}

# Consumption budget subscription resource id
locals {
  consumption_budget_subscription_resource_id = "/subscriptions/${local.subscription_id}/providers/Microsoft.Consumption/budgets/${local.azurerm_consumption_budget_subscription.name}"
}

# Generate the configuration output object for the landing zones module
locals {
  module_output = {
    template_file_variables    = local.template_file_variables
    azurerm_resource_group = [
      for resource in local.azurerm_resource_group :
      {
        resource_id   = resource.resource_id
        resource_name = resource.name
        template = {
          for key, value in resource :
          key => value
          if local.deploy_landingzones &&
          key != "resource_id" &&
          key != "managed_by_module"
        }
        managed_by_module = local.deploy_landingzones
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
    azurerm_role_assignment = [
      for resource in local.azurerm_role_assignment :
      {
        resource_name = resource.principal_id
        template = {
          for key, value in resource :
          key => value
          if local.deploy_landingzones &&
          key != "managed_by_module"
        }
        managed_by_module = local.deploy_landingzones
      }
    ]
    azurerm_monitor_action_group = [
      {
        resource_name = local.azurerm_monitor_action_group.name
        template = {
          for key, value in local.azurerm_monitor_action_group :
          key => value
          if local.deploy_landingzones
        }
        managed_by_module = local.deploy_landingzones
      },
    ]
    azurerm_consumption_budget_subscription = [
      {
        resource_id   = local.consumption_budget_subscription_resource_id
        resource_name = basename(local.consumption_budget_subscription_resource_id)
        template = {
          for key, value in local.azurerm_consumption_budget_subscription :
          key => value
          if local.deploy_landingzones
        }
        managed_by_module = local.deploy_landingzones
      },
    ]
  }
}
