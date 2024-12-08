resource "azurerm_resource_group" "extended_vwan" {
  for_each = local.azurerm_resource_group_extended_vwan

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name     = each.value.template.name
  location = each.value.template.location
  tags     = each.value.template.tags
}

resource "azurerm_virtual_network" "extended_vwan" {
  for_each = local.azurerm_virtual_network_bastion

  provider = azurerm.connectivity

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
    azurerm_resource_group.extended_vwan,
  ]

}

resource "azurerm_subnet" "extended_vwan" {
  for_each = local.azurerm_ext_vwan_bastion_subnet

  provider = azurerm.connectivity

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
    azurerm_resource_group.extended_vwan,
    azurerm_virtual_network.extended_vwan
  ]
}

resource "azurerm_network_security_group" "extended_vwan" {
  for_each = local.azurerm_ext_vwan_bastion_nsg

  provider = azurerm.connectivity

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
    azurerm_resource_group.extended_vwan,
    azurerm_virtual_network.extended_vwan
  ]
}

resource "azurerm_subnet_network_security_group_association" "extended_vwan" {
  for_each = local.azurerm_ext_vwan_bastion_network_security_group_association

  provider = azurerm.connectivity

  # Mandatory resource attributes
  subnet_id                 = each.value.template.subnet_id
  network_security_group_id = each.value.template.network_security_group_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.extended_vwan,
    azurerm_subnet.extended_vwan,
    azurerm_network_security_group.extended_vwan,
  ]
}

/*
resource "azurerm_virtual_network_peering" "extended_vwan"{
  for_each = local.azurerm_ext_vwan_bastion_virtual_network_peering

  provider = azurerm.connectivity

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
    azurerm_resource_group.extended_vwan,
    azurerm_virtual_network.extended_vwan,
  ]
}*/


resource "azurerm_bastion_host" "extended_vwan" {
  for_each = local.azurerm_ext_vwan_bastion_host

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name
  location            = each.value.template.location

  ip_configuration {
    name                 = "configuration"
    subnet_id            = each.value.template.subnet_id
    public_ip_address_id = each.value.template.public_ip_address_id
  }

  # Optional resource attributes
  sku = each.value.template.sku

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.extended_vwan,
    azurerm_virtual_network.extended_vwan,
    azurerm_subnet.extended_vwan,
    azurerm_public_ip.connectivity,
  ]
}

/*resource "azurerm_public_ip" "extended_vwan" {
  for_each = local.azurerm_ext_vwan_public_ip

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = each.value.template.name
  location            = each.value.template.location
  resource_group_name = each.value.template.resource_group_name
  allocation_method   = each.value.template.allocation_method

  # Optional resource attributes
  sku                     = each.value.template.sku
  zones                   = each.value.template.zones
  ip_version              = each.value.template.ip_version
  idle_timeout_in_minutes = each.value.template.idle_timeout_in_minutes
  domain_name_label       = each.value.template.domain_name_label
  reverse_fqdn            = each.value.template.reverse_fqdn
  public_ip_prefix_id     = each.value.template.public_ip_prefix_id
  ip_tags                 = each.value.template.ip_tags
  tags                    = each.value.template.tags

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.extended_vwan,
  ]

}*/

/*resource "azurerm_virtual_hub_connection" "extended_vwan" {
  for_each = local.azurerm_ext_virtual_hub_connection

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                      = each.value.template.name
  virtual_hub_id            = each.value.template.virtual_hub_id
  remote_virtual_network_id = each.value.template.remote_virtual_network_id

  # Optional resource attributes
  internet_security_enabled = each.value.template.internet_security_enabled

  # Dynamic configuration blocks
  dynamic "routing" {
    for_each = each.value.template.routing
    content {
      # Optional attributes
      associated_route_table_id = lookup(routing.value, "associated_route_table_id", null)
      dynamic "propagated_route_table" {
        for_each = lookup(routing.value, "propagated_route_table", local.empty_list)
        content {
          # Optional attributes
          labels          = lookup(propagated_route_table.value, "labels", null)
          route_table_ids = lookup(propagated_route_table.value, "route_table_ids", null)
        }
      }
      dynamic "static_vnet_route" {
        for_each = lookup(routing.value, "static_vnet_route", local.empty_list)
        content {
          # Optional attributes
          name                = lookup(static_vnet_route.value, "name", null)
          address_prefixes    = lookup(static_vnet_route.value, "address_prefixes", null)
          next_hop_ip_address = lookup(static_vnet_route.value, "next_hop_ip_address", null)
        }
      }
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.extended_vwan,
    azurerm_resource_group.virtual_wan,
    azurerm_virtual_wan.virtual_wan,
    azurerm_virtual_hub.virtual_wan,
  ]

}*/

resource "azurerm_virtual_network" "extended_vwan_dns" {
  for_each = local.azurerm_virtual_network_dns

  provider = azurerm.connectivity

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
    azurerm_resource_group.extended_vwan,
  ]

}

resource "azurerm_subnet" "extended_vwan_dns" {
  for_each = local.azurerm_ext_vwan_dns_subnet

  provider = azurerm.connectivity

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
    azurerm_resource_group.extended_vwan,
    azurerm_virtual_network.extended_vwan_dns
  ]
}

/*resource "azurerm_network_security_group" "extended_vwan_dns" {
  for_each = local.azurerm_ext_vwan_dns_nsg

  provider = azurerm.connectivity

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
    azurerm_resource_group.extended_vwan,
    azurerm_virtual_network.extended_vwan_dns
  ]
}

resource "azurerm_subnet_network_security_group_association" "extended_vwan_dns"{
  for_each = local.azurerm_ext_vwan_dns_network_security_group_association

  provider = azurerm.connectivity

  # Mandatory resource attributes
  subnet_id                 = each.value.template.subnet_id
  network_security_group_id = each.value.template.network_security_group_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.extended_vwan,
    azurerm_subnet.extended_vwan_dns,
    azurerm_network_security_group.extended_vwan_dns,
  ]
}*/
resource "azurerm_private_dns_resolver" "extended_vwan_dns" {
  for_each = local.azurerm_ext_private_dns_resolver_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name
  location            = each.value.template.location
  virtual_network_id  = each.value.template.virtual_network_id

  # Optional resource attributes
  tags = each.value.template.tags

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.extended_vwan,
    azurerm_virtual_network.extended_vwan_dns
  ]

}

resource "azurerm_private_dns_resolver_inbound_endpoint" "extended_vwan_dns" {
  for_each = local.azurerm_ext_private_dns_resolver_inbound_endpoint_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                    = each.value.template.name
  location                = each.value.template.location
  private_dns_resolver_id = each.value.template.private_dns_resolver_id
  dynamic "ip_configurations" {
    for_each = each.value.template.ip_configurations
    content {
      private_ip_allocation_method = ip_configurations.value["private_ip_allocation_method"]
      subnet_id                    = ip_configurations.value["subnet_id"]
    }
  }
  # ip_configurations   = each.value.template.ip_configurations

  # Optional resource attributes
  tags = each.value.template.tags

  # Set explicit dependencies
  depends_on = [
    azurerm_subnet.extended_vwan_dns,
    azurerm_private_dns_resolver.extended_vwan_dns,
  ]

}

resource "azurerm_private_dns_resolver_outbound_endpoint" "extended_vwan_dns" {
  for_each = local.azurerm_ext_private_dns_resolver_outbound_endpoint_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                    = each.value.template.name
  location                = each.value.template.location
  private_dns_resolver_id = each.value.template.private_dns_resolver_id
  subnet_id               = each.value.template.subnet_id

  # Optional resource attributes
  tags = each.value.template.tags

  # Set explicit dependencies
  depends_on = [
    azurerm_private_dns_resolver_inbound_endpoint.extended_vwan_dns
  ]

}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "extended_vwan_dns" {
  for_each = local.azurerm_ext_private_dns_resolver_dns_forwarding_ruleset_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                                       = each.value.template.name
  resource_group_name                        = each.value.template.resource_group_name
  location                                   = each.value.template.location
  private_dns_resolver_outbound_endpoint_ids = each.value.template.private_dns_resolver_outbound_endpoint_ids

  # Optional resource attributes
  tags = each.value.template.tags

  # Set explicit dependencies
  depends_on = [
    azurerm_private_dns_resolver_outbound_endpoint.extended_vwan_dns
  ]

}

resource "azurerm_private_dns_resolver_forwarding_rule" "extended_vwan_dns" {
  for_each = local.azurerm_ext_private_dns_resolver_forwarding_rule_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                      = each.value.template.name
  dns_forwarding_ruleset_id = each.value.template.dns_forwarding_ruleset_id
  domain_name               = each.value.template.domain_name
  enabled                   = each.value.template.enabled
  dynamic "target_dns_servers" {
    for_each = each.value.template.target_dns_servers
    content {
      ip_address = target_dns_servers.value["ip_address"]
      port       = target_dns_servers.value["port"]
    }
  }
  # target_dns_servers = each.value.template.target_dns_servers
  # metadata {
  #   for_each = each.value.template.metadata

  #   key = metadata.value["key"]
  # }
  metadata = each.value.template.metadata

  # Set explicit dependencies
  depends_on = [
    azurerm_private_dns_resolver_dns_forwarding_ruleset.extended_vwan_dns
  ]
}

