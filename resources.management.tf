resource "azurerm_resource_group" "management" {
  for_each = local.azurerm_resource_group_management

  provider = azurerm.management

  # Mandatory resource attributes
  name     = each.value.template.name
  location = each.value.template.location
  tags     = each.value.template.tags
}

resource "azurerm_virtual_network" "management" {
  for_each = local.azurerm_virtual_network_management

  provider = azurerm.management

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name
  address_space       = each.value.template.address_space
  location            = each.value.template.location

  # Optional resource attributes
  bgp_community = each.value.template.bgp_community
  dns_servers   = each.value.template.dns_servers
  tags          = each.value.template.tags

  # Dynamic configuration blocks
  # Subnets excluded (use azurerm_subnet resource)
  dynamic "ddos_protection_plan" {
    for_each = each.value.template.ddos_protection_plan
    content {
      id     = ddos_protection_plan.value["id"]
      enable = ddos_protection_plan.value["enable"]
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.management,
  ]
}

resource "azurerm_subnet" "management" {
  for_each = local.azurerm_subnet_management

  provider = azurerm.management

  # Mandatory resource attributes
  name                 = each.value.template.name
  resource_group_name  = each.value.template.resource_group_name
  virtual_network_name = each.value.template.virtual_network_name
  address_prefixes     = each.value.template.address_prefixes

  # Optional resource attributes
  private_endpoint_network_policies             = each.value.template.private_endpoint_network_policies
  private_link_service_network_policies_enabled = each.value.template.private_link_service_network_policies_enabled
  service_endpoints                             = each.value.template.service_endpoints
  service_endpoint_policy_ids                   = each.value.template.service_endpoint_policy_ids

  # Dynamic configuration blocks
  # Subnets excluded (use azurerm_subnet resource)
  dynamic "delegation" {
    for_each = each.value.template.delegation
    content {
      name = delegation.value["name"]

      dynamic "service_delegation" {
        for_each = delegation.value["service_delegation"]
        content {
          name    = service_delegation.value["name"]
          actions = try(service_delegation.value["actions"], null)
        }
      }
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.management,
    azurerm_virtual_network.management,
  ]
}

resource "azurerm_network_security_group" "management" {
  for_each = local.azurerm_network_security_group_management

  provider = azurerm.management

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name
  location            = each.value.template.location

  # Optional resource attributes
  tags = each.value.template.tags

  # Dynamic configuration blocks
  dynamic "security_rule" {
    for_each = each.value.template.security_rule
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.management,
    azurerm_virtual_network.management,
  ]
}

resource "azurerm_route_table" "management" {
  for_each = local.azurerm_route_table_management

  provider = azurerm.management

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name
  location            = each.value.template.location

  # Optional resource attributes
  bgp_route_propagation_enabled = each.value.template.bgp_route_propagation_enabled
  tags                          = each.value.template.tags

  # Dynamic configuration blocks
  dynamic "route" {
    for_each = each.value.template.route
    content {
      name                   = route.value["name"]
      address_prefix         = route.value["address_prefix"]
      next_hop_type          = route.value["next_hop_type"]
      next_hop_in_ip_address = route.value["next_hop_in_ip_address"]
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.management,
    azurerm_virtual_network.management,
  ]
}

resource "azurerm_subnet_route_table_association" "management" {
  for_each = local.azurerm_subnet_route_table_association_management

  provider = azurerm.management

  # Mandatory resource attributes
  subnet_id      = each.value.template.subnet_id
  route_table_id = each.value.template.route_table_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.management,
    azurerm_subnet.management,
    azurerm_route_table.management,
  ]
}

resource "azurerm_subnet_network_security_group_association" "management" {
  for_each = local.azurerm_subnet_network_security_group_association_management

  provider = azurerm.management

  # Mandatory resource attributes
  subnet_id                 = each.value.template.subnet_id
  network_security_group_id = each.value.template.network_security_group_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.management,
    azurerm_subnet.management,
    azurerm_network_security_group.management,
  ]
}

resource "azurerm_storage_account" "management" {
  for_each = local.azurerm_storage_account_management

  provider = azurerm.management

  # Mandatory resource attributes
  name                = each.value.template.name
  location            = each.value.template.location
  resource_group_name = each.value.template.resource_group_name

  # Optional resource attributes
  account_tier             = each.value.template.account_tier
  account_replication_type = each.value.template.account_replication_type
  tags                     = each.value.template.tags

  # Set explicit dependency on Resource Group deployment
  depends_on = [
    azurerm_resource_group.management,
  ]

}

resource "azurerm_log_analytics_workspace" "management" {
  for_each = local.azurerm_log_analytics_workspace_management

  provider = azurerm.management

  # Mandatory resource attributes
  name                = each.value.template.name
  location            = each.value.template.location
  resource_group_name = each.value.template.resource_group_name

  # Optional resource attributes
  sku                                = each.value.template.sku
  retention_in_days                  = each.value.template.retention_in_days
  daily_quota_gb                     = each.value.template.daily_quota_gb
  cmk_for_query_forced               = each.value.template.cmk_for_query_forced
  internet_ingestion_enabled         = each.value.template.internet_ingestion_enabled
  internet_query_enabled             = each.value.template.internet_query_enabled
  reservation_capacity_in_gb_per_day = each.value.template.reservation_capacity_in_gb_per_day
  tags                               = each.value.template.tags

  # allow_resource_only_permissions = each.value.template.allow_resource_only_permissions # Available only in v3.36.0 onwards

  # Set explicit dependency on Resource Group deployment
  depends_on = [
    azurerm_resource_group.management,
  ]

}

resource "azurerm_log_analytics_solution" "management" {
  for_each = local.azurerm_log_analytics_solution_management

  provider = azurerm.management

  # Mandatory resource attributes
  solution_name         = each.value.template.solution_name
  location              = each.value.template.location
  resource_group_name   = each.value.template.resource_group_name
  workspace_resource_id = each.value.template.workspace_resource_id
  workspace_name        = each.value.template.workspace_name

  plan {
    publisher = each.value.template.plan.publisher
    product   = each.value.template.plan.product
  }

  # Optional resource attributes
  tags = each.value.template.tags

  # Set explicit dependency on Resource Group, Log Analytics
  # workspace and Automation Account to fix issue #109.
  # Ideally we would limit to specific solutions, but the
  # depends_on block only supports static values.
  depends_on = [
    azurerm_resource_group.management,
    azurerm_log_analytics_workspace.management,
    azurerm_automation_account.management,
    azurerm_log_analytics_linked_service.management,
    azurerm_log_analytics_linked_storage_account.management,
    azurerm_storage_account.management
  ]

}

resource "azurerm_automation_account" "management" {
  for_each = local.azurerm_automation_account_management

  provider = azurerm.management

  # Mandatory resource attributes
  name                = each.value.template.name
  location            = each.value.template.location
  resource_group_name = each.value.template.resource_group_name

  # Optional resource attributes
  sku_name                      = each.value.template.sku_name
  public_network_access_enabled = each.value.template.public_network_access_enabled
  local_authentication_enabled  = each.value.template.local_authentication_enabled
  tags                          = each.value.template.tags

  # Dynamic configuration blocks
  dynamic "identity" {
    for_each = each.value.template.identity
    content {
      # Mandatory attributes
      type = identity.value.type
      # Optional attributes
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  dynamic "encryption" {
    for_each = each.value.template.encryption
    content {
      # Mandatory attributes
      key_vault_key_id = encryption.value["key_vault_key_id"]
      # Optional attributes
      user_assigned_identity_id = lookup(encryption.value, "user_assigned_identity_id", null)
      key_source                = lookup(encryption.value, "key_source", null)
    }
  }

  # Set explicit dependency on Resource Group deployment
  depends_on = [
    azurerm_resource_group.management,
    azurerm_storage_account.management
  ]

}

resource "azurerm_log_analytics_linked_service" "management" {
  for_each = local.azurerm_log_analytics_linked_service_management

  provider = azurerm.management

  # Mandatory resource attributes
  resource_group_name = each.value.template.resource_group_name
  workspace_id        = each.value.template.workspace_id

  # Optional resource attributes
  read_access_id  = each.value.template.read_access_id
  write_access_id = each.value.template.write_access_id

  # Set explicit dependency on Resource Group, Log Analytics workspace and Automation Account deployments
  depends_on = [
    azurerm_resource_group.management,
    azurerm_log_analytics_workspace.management,
    azurerm_automation_account.management,
    azurerm_storage_account.management
  ]

}
resource "azurerm_log_analytics_linked_storage_account" "management" {
  for_each = local.azurerm_log_analytics_linked_storage_account_management

  provider = azurerm.management

  # Mandatory resource attributes
  data_source_type      = each.value.template.data_source_type
  resource_group_name   = each.value.template.resource_group_name
  workspace_resource_id = each.value.template.workspace_resource_id
  storage_account_ids   = each.value.template.storage_account_ids

  # Set explicit dependency on Resource Group, Log Analytics workspace and Automation Account deployments
  depends_on = [
    azurerm_resource_group.management,
    azurerm_log_analytics_workspace.management,
    azurerm_automation_account.management,
    azurerm_storage_account.management
  ]

}

resource "azurerm_virtual_network_peering" "management" {
  for_each = local.azurerm_virtual_network_peering_management

  provider = azurerm.management

  # Mandatory resource attributes
  name                      = each.value.template.name
  resource_group_name       = each.value.template.resource_group_name
  virtual_network_name      = each.value.template.virtual_network_name
  remote_virtual_network_id = each.value.template.remote_virtual_network_id

  # Optional resource attributes
  allow_virtual_network_access = each.value.template.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.template.allow_forwarded_traffic
  allow_gateway_transit        = each.value.template.allow_gateway_transit
  use_remote_gateways          = each.value.template.use_remote_gateways

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.management,
    azurerm_virtual_network.management,
  ]
}


resource "azurerm_monitor_action_group" "management" {
  for_each = local.azurerm_monitor_action_group_management

  provider = azurerm.management

  # Mandatory resource attributes
  name                = each.value.template.name
  short_name          = each.value.template.action_group_shortname
  resource_group_name = each.value.template.resource_group_name
  tags                = each.value.template.tags

  # Optional resource attributes
  email_receiver {
    name          = each.value.template.email_receiver.name
    email_address = each.value.template.email_receiver.email_address
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.management,
  ]
}
