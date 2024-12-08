resource "azurerm_resource_group" "landingzones" {
  for_each = local.azurerm_resource_group_landingzones

  provider = azurerm.landingzones

  # Mandatory resource attributes
  name     = each.value.template.name
  location = each.value.template.location
  tags     = each.value.template.tags
}

resource "azurerm_virtual_network" "landingzones" {
  for_each = local.azurerm_virtual_network_landingzones

  provider = azurerm.landingzones

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
    azurerm_resource_group.landingzones,
  ]
}

resource "azurerm_subnet" "landingzones" {
  for_each = local.azurerm_subnet_landingzones

  provider = azurerm.landingzones

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
    azurerm_resource_group.landingzones,
    azurerm_virtual_network.landingzones,
  ]
}

resource "azurerm_network_security_group" "landingzones" {
  for_each = local.azurerm_network_security_group_landingzones

  provider = azurerm.landingzones

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
      name                         = security_rule.value["name"]
      priority                     = security_rule.value["priority"]
      direction                    = security_rule.value["direction"]
      access                       = security_rule.value["access"]
      protocol                     = security_rule.value["protocol"]
      source_port_range            = security_rule.value["source_port_range"]
      source_port_ranges           = security_rule.value["source_port_ranges"]
      destination_port_range       = security_rule.value["destination_port_range"]
      destination_port_ranges      = security_rule.value["destination_port_ranges"]
      source_address_prefix        = security_rule.value["source_address_prefix"]
      source_address_prefixes      = security_rule.value["source_address_prefixes"]
      destination_address_prefix   = security_rule.value["destination_address_prefix"]
      destination_address_prefixes = security_rule.value["destination_address_prefixes"]
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.landingzones,
    azurerm_virtual_network.landingzones,
  ]
}

resource "azurerm_route_table" "landingzones" {
  for_each = local.azurerm_route_table_landingzones

  provider = azurerm.landingzones

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
    azurerm_resource_group.landingzones,
    azurerm_virtual_network.landingzones,
  ]
}

resource "azurerm_subnet_route_table_association" "landingzones" {
  for_each = local.azurerm_subnet_route_table_association_landingzones

  provider = azurerm.landingzones

  # Mandatory resource attributes
  subnet_id      = each.value.template.subnet_id
  route_table_id = each.value.template.route_table_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.landingzones,
    azurerm_subnet.landingzones,
    azurerm_route_table.landingzones,
  ]
}

resource "azurerm_subnet_network_security_group_association" "landingzones" {
  for_each = local.azurerm_subnet_network_security_group_association_landingzones

  provider = azurerm.landingzones

  # Mandatory resource attributes
  subnet_id                 = each.value.template.subnet_id
  network_security_group_id = each.value.template.network_security_group_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.landingzones,
    azurerm_subnet.landingzones,
    azurerm_network_security_group.landingzones,
  ]
}

resource "azurerm_virtual_network_peering" "landingzones" {
  for_each = local.azurerm_virtual_network_peering_landingzones

  provider = azurerm.landingzones

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
    azurerm_resource_group.landingzones,
    azurerm_virtual_network.landingzones,
  ]
}

resource "azurerm_role_assignment" "landingzones" {
  for_each = local.azurerm_role_assignment_landingzones

  provider = azurerm.landingzones

  scope                            = each.value.template.scope
  role_definition_id               = each.value.template.role_definition_id
  principal_id                     = each.value.template.principal_id
  skip_service_principal_aad_check = each.value.template.skip_service_principal_aad_check

  depends_on = [
    azurerm_resource_group.landingzones
  ]
}

resource "azurerm_monitor_action_group" "landingzones" {
  for_each = local.azurerm_monitor_action_group_landingzones

  provider = azurerm.landingzones

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
    azurerm_resource_group.landingzones,
  ]
}

resource "azurerm_consumption_budget_subscription" "landingzones" {
  for_each = local.azurerm_consumption_budget_subscription_landingzones

  provider = azurerm.landingzones

  # Mandatory resource attributes
  name            = each.value.template.name
  subscription_id = each.value.template.subscription_id
  amount          = each.value.template.amount
  time_period {
    start_date = each.value.template.start_date
    end_date   = each.value.template.end_date
  }
  notification {
    enabled        = each.value.template.enable_notifications
    threshold      = each.value.template.threshold
    operator       = each.value.template.operator
    contact_groups = each.value.template.contact_groups
  }

  # Optional resource attributes

  # Set explicit dependencies
  depends_on = [
    azurerm_monitor_action_group.landingzones,
  ]
}
