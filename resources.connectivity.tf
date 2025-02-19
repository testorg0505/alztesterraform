resource "azurerm_resource_group" "connectivity" {
  for_each = local.azurerm_resource_group_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name     = each.value.template.name
  location = each.value.template.location
  tags     = each.value.template.tags
}

resource "azurerm_virtual_network" "connectivity" {
  for_each = local.azurerm_virtual_network_connectivity

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
    azurerm_resource_group.connectivity,
    azurerm_network_ddos_protection_plan.connectivity,
  ]

}

resource "azurerm_subnet" "connectivity" {
  for_each = local.azurerm_subnet_connectivity

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
    azurerm_resource_group.connectivity,
    azurerm_virtual_network.connectivity,
    azurerm_network_ddos_protection_plan.connectivity,
  ]

}



resource "azurerm_subnet_route_table_association" "connectivity" {
  for_each = local.azurerm_subnet_route_table_association_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  subnet_id      = each.value.template.subnet_id
  route_table_id = each.value.template.route_table_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.connectivity,
    azurerm_subnet.connectivity
  ]
}

resource "azurerm_subnet_network_security_group_association" "connectivity" {
  for_each = local.azurerm_subnet_network_security_group_association_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  subnet_id                 = each.value.template.subnet_id
  network_security_group_id = each.value.template.network_security_group_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.connectivity,
    azurerm_subnet.connectivity
  ]
}


resource "azurerm_bastion_host" "connectivity" {
  for_each = local.azurerm_bastion_host_connectivity

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
    azurerm_resource_group.connectivity,
    azurerm_virtual_network.connectivity,
    azurerm_subnet.connectivity,
    azurerm_public_ip.connectivity,
  ]

}

resource "azurerm_network_ddos_protection_plan" "connectivity" {
  for_each = local.azurerm_network_ddos_protection_plan_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = each.value.template.name
  location            = each.value.template.location
  resource_group_name = each.value.template.resource_group_name

  # Optional resource attributes
  tags = each.value.template.tags

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.connectivity,
  ]

}

resource "azurerm_public_ip" "connectivity" {
  for_each = local.azurerm_public_ip_connectivity

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
    azurerm_resource_group.connectivity,
    azurerm_resource_group.extended_vwan,
  ]

}

resource "azurerm_virtual_network_gateway" "connectivity" {
  for_each = local.azurerm_virtual_network_gateway_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name
  location            = each.value.template.location
  type                = each.value.template.type

  # Optional resource attributes
  vpn_type                         = each.value.template.vpn_type
  enable_bgp                       = each.value.template.enable_bgp
  active_active                    = each.value.template.active_active
  private_ip_address_enabled       = each.value.template.private_ip_address_enabled
  default_local_network_gateway_id = each.value.template.default_local_network_gateway_id
  sku                              = each.value.template.sku
  generation                       = each.value.template.generation
  tags                             = each.value.template.tags

  # Dynamic configuration blocks
  dynamic "ip_configuration" {
    for_each = each.value.template.ip_configuration
    content {
      # Mandatory attributes
      subnet_id            = ip_configuration.value["subnet_id"]
      public_ip_address_id = ip_configuration.value["public_ip_address_id"]
      # Optional attributes
      name                          = try(ip_configuration.value["name"], null)
      private_ip_address_allocation = try(ip_configuration.value["private_ip_address_allocation"], null)
    }
  }

  dynamic "vpn_client_configuration" {
    for_each = each.value.template.vpn_client_configuration
    content {
      # Mandatory attributes
      address_space = vpn_client_configuration.value["address_space"]
      # Optional attributes
      aad_tenant            = try(vpn_client_configuration.value["aad_tenant"], null)
      aad_audience          = try(vpn_client_configuration.value["aad_audience"], null)
      aad_issuer            = try(vpn_client_configuration.value["aad_issuer"], null)
      radius_server_address = try(vpn_client_configuration.value["radius_server_address"], null)
      radius_server_secret  = try(vpn_client_configuration.value["radius_server_secret"], null)
      vpn_client_protocols  = try(vpn_client_configuration.value["vpn_client_protocols"], null)
      vpn_auth_types        = try(vpn_client_configuration.value["vpn_auth_types"], null)

      dynamic "root_certificate" {
        for_each = try(vpn_client_configuration.value["root_certificate"], local.empty_list)
        content {
          name             = root_certificate.value["name"]
          public_cert_data = root_certificate.value["public_cert_data"]
        }
      }

      dynamic "revoked_certificate" {
        for_each = try(vpn_client_configuration.value["revoked_certificate"], local.empty_list)
        content {
          name       = revoked_certificate.value["name"]
          thumbprint = revoked_certificate.value["thumbprint"]
        }
      }
    }
  }

  dynamic "bgp_settings" {
    for_each = each.value.template.bgp_settings
    content {
      # Optional attributes
      asn         = try(bgp_settings.value["asn"], null)
      peer_weight = try(bgp_settings.value["peer_weight"], null)

      dynamic "peering_addresses" {
        for_each = try(bgp_settings.value["peering_addresses"], local.empty_list)
        content {
          ip_configuration_name = try(peering_addresses.value["ip_configuration_name"], null)
          apipa_addresses       = try(peering_addresses.value["apipa_addresses"], null)
        }
      }
    }
  }

  dynamic "custom_route" {
    for_each = each.value.template.custom_route
    content {
      # Optional attributes
      address_prefixes = try(custom_route.value["address_prefixes"], null)
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.connectivity,
    azurerm_virtual_network.connectivity,
    azurerm_subnet.connectivity,
    azurerm_public_ip.connectivity,
    azurerm_network_ddos_protection_plan.connectivity,
  ]

}

resource "azurerm_firewall_policy" "connectivity" {
  for_each = local.azurerm_firewall_policy_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name
  location            = each.value.template.location

  # Optional resource attributes
  base_policy_id           = each.value.template.base_policy_id
  private_ip_ranges        = each.value.template.private_ip_ranges
  sku                      = each.value.template.sku
  tags                     = each.value.template.tags
  threat_intelligence_mode = each.value.template.threat_intelligence_mode # "Alert", "Deny" or "Off". Defaults to "Alert"
  sql_redirect_allowed     = each.value.template.sql_redirect_allowed

  # Dynamic configuration blocks
  dynamic "dns" {
    for_each = each.value.template.dns
    content {
      # Optional attributes
      proxy_enabled = lookup(dns.value, "proxy_enabled", null)
      servers       = lookup(dns.value, "servers", null)
    }
  }

  dynamic "identity" {
    for_each = each.value.template.identity
    content {
      # Mandatory attributes
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "insights" {
    for_each = each.value.template.insights
    content {
      # Mandatory attributes
      enabled                            = insights.value.enabled
      default_log_analytics_workspace_id = insights.value.default_log_analytics_workspace_id
      # Optional attributes
      retention_in_days = lookup(insights.value, "retention_in_days", null)
      # Dynamic configuration blocks
      dynamic "log_analytics_workspace" {
        for_each = lookup(insights.value, "log_analytics_workspace", local.empty_list)
        content {
          # Mandatory attributes
          id                = log_analytics_workspace.value["id"]
          firewall_location = log_analytics_workspace.value["firewall_location"]
        }
      }
    }
  }

  dynamic "intrusion_detection" {
    for_each = each.value.template.intrusion_detection
    content {
      # Optional attributes
      mode = lookup(intrusion_detection.value, "mode", null) # "Off", "Alert" or "Deny"
      # Dynamic configuration blocks
      dynamic "signature_overrides" {
        for_each = lookup(intrusion_detection.value, "signature_overrides", local.empty_list)
        content {
          # Optional attributes
          id    = lookup(signature_overrides.value, "id", null)
          state = lookup(signature_overrides.value, "state", null)
        }
      }
      dynamic "traffic_bypass" {
        for_each = lookup(intrusion_detection.value, "traffic_bypass", local.empty_list)
        content {
          # Mandatory attributes
          name     = traffic_bypass.value["name"]
          protocol = traffic_bypass.value["protocol"]
          # Optional attributes
          description           = lookup(traffic_bypass.value, "description", null)
          destination_addresses = lookup(traffic_bypass.value, "destination_addresses", null)
          destination_ip_groups = lookup(traffic_bypass.value, "destination_ip_groups", null)
          destination_ports     = lookup(traffic_bypass.value, "destination_ports", null)
          source_addresses      = lookup(traffic_bypass.value, "source_addresses", null)
          source_ip_groups      = lookup(traffic_bypass.value, "source_ip_groups", null)
        }
      }
    }
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = each.value.template.threat_intelligence_allowlist
    content {
      # Optional attributes
      fqdns        = lookup(threat_intelligence_allowlist.value, "fqdns", null)
      ip_addresses = lookup(threat_intelligence_allowlist.value, "ip_addresses", null)
    }
  }

  dynamic "tls_certificate" {
    for_each = each.value.template.tls_certificate
    content {
      # Mandatory attributes
      key_vault_secret_id = tls_certificate.value["key_vault_secret_id"]
      name                = tls_certificate.value["name"]
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.connectivity,
    azurerm_resource_group.virtual_wan,
  ]

}

resource "azurerm_firewall_policy_rule_collection_group" "connectivity" {
  for_each = local.azurerm_firewall_policy_rule_collection_group_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name               = each.value.template.name
  firewall_policy_id = each.value.template.firewall_policy_id
  priority           = each.value.template.priority
  dynamic "application_rule_collection" {
    for_each = each.value.template.application_rule_collection
    content {
      name     = application_rule_collection.value["name"]
      priority = application_rule_collection.value["priority"]
      action   = application_rule_collection.value["action"]
      dynamic "rule" {
        for_each = application_rule_collection.value["rule"]
        content {
          name        = rule.value["name"]
          description = rule.value["description"]
          dynamic "protocols" {
            for_each = rule.value["protocols"]
            content {
              type = protocols.value["type"]
              port = protocols.value["port"]
            }
          }
          dynamic "http_headers" {
            for_each = rule.value["http_headers"]
            content {
              name  = http_headers.value["name"]
              value = http_headers.value["value"]
            }
          }
          source_addresses      = rule.value["source_addresses"]
          source_ip_groups      = rule.value["source_ip_groups"]
          destination_addresses = rule.value["destination_addresses"]
          destination_urls      = rule.value["destination_urls"]
          destination_fqdns     = rule.value["destination_fqdns"]
          destination_fqdn_tags = rule.value["destination_fqdn_tags"]
          terminate_tls         = rule.value["terminate_tls"]
          web_categories        = rule.value["web_categories"]
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = each.value.template.network_rule_collection
    content {
      name     = network_rule_collection.value["name"]
      priority = network_rule_collection.value["priority"]
      action   = network_rule_collection.value["action"]
      dynamic "rule" {
        for_each = network_rule_collection.value["rule"]
        content {
          name                  = rule.value["name"]
          description           = rule.value["description"]
          protocols             = rule.value["protocols"]
          destination_ports     = rule.value["destination_ports"]
          source_addresses      = rule.value["source_addresses"]
          source_ip_groups      = rule.value["source_ip_groups"]
          destination_addresses = rule.value["destination_addresses"]
          destination_ip_groups = rule.value["destination_ip_groups"]
          destination_fqdns     = rule.value["destination_fqdns"]
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = each.value.template.nat_rule_collection
    content {
      name     = nat_rule_collection.value["name"]
      priority = nat_rule_collection.value["priority"]
      action   = nat_rule_collection.value["action"]
      dynamic "rule" {
        for_each = nat_rule_collection.value["rule"]
        content {
          name                = rule.value["name"]
          description         = rule.value["description"]
          protocols           = rule.value["protocols"]
          source_addresses    = rule.value["source_addresses"]
          source_ip_groups    = rule.value["source_ip_groups"]
          destination_address = rule.value["destination_address"]
          destination_ports   = rule.value["destination_ports"]
          translated_address  = rule.value["translated_address"]
          translated_port     = rule.value["translated_port"]
        }
      }
    }
  }

  depends_on = [
    azurerm_resource_group.connectivity,
    azurerm_resource_group.virtual_wan,
    azurerm_firewall_policy.connectivity
  ]
}

resource "azurerm_firewall" "connectivity" {
  for_each = local.azurerm_firewall_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name
  location            = each.value.template.location

  # Optional resource attributes
  sku_name           = each.value.template.sku_name
  sku_tier           = each.value.template.sku_tier
  firewall_policy_id = each.value.template.firewall_policy_id
  dns_servers        = each.value.template.dns_servers
  private_ip_ranges  = each.value.template.private_ip_ranges
  threat_intel_mode  = each.value.template.threat_intel_mode
  zones              = each.value.template.zones
  tags               = each.value.template.tags

  # Dynamic configuration blocks
  dynamic "ip_configuration" {
    for_each = each.value.template.ip_configuration
    content {
      # Mandatory attributes
      name                 = ip_configuration.value["name"]
      public_ip_address_id = ip_configuration.value["public_ip_address_id"]
      # Optional attributes
      subnet_id = try(ip_configuration.value["subnet_id"], null)
    }
  }

  dynamic "management_ip_configuration" {
    for_each = each.value.template.management_ip_configuration
    content {
      # Mandatory attributes
      name                 = management_ip_configuration.value["name"]
      public_ip_address_id = management_ip_configuration.value["public_ip_address_id"]
      # Optional attributes
      subnet_id = try(management_ip_configuration.value["subnet_id"], null)
    }
  }

  dynamic "virtual_hub" {
    for_each = each.value.template.virtual_hub
    content {
      # Mandatory attributes
      virtual_hub_id = virtual_hub.value["virtual_hub_id"]
      # Optional attributes
      public_ip_count = try(virtual_hub.value["public_ip_count"], null)
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.connectivity,
    azurerm_virtual_network.connectivity,
    azurerm_subnet.connectivity,
    azurerm_public_ip.connectivity,
    azurerm_network_ddos_protection_plan.connectivity,
    azurerm_firewall_policy.connectivity,
  ]

}

resource "azurerm_private_dns_zone" "connectivity" {
  for_each = local.azurerm_private_dns_zone_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name

  # Optional resource attributes
  tags = each.value.template.tags

  # Dynamic configuration blocks
  dynamic "soa_record" {
    for_each = each.value.template.soa_record
    content {
      # Mandatory attributes
      email = soa_record.value["email"]
      # Optional attributes
      expire_time  = try(soa_record.value["expire_time"], null)
      minimum_ttl  = try(soa_record.value["minimum_ttl"], null)
      refresh_time = try(soa_record.value["refresh_time"], null)
      retry_time   = try(soa_record.value["retry_time"], null)
      ttl          = try(soa_record.value["ttl"], null)
      tags         = try(soa_record.value["tags"], each.value.template.tags)
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.connectivity,
  ]

}

resource "azurerm_private_dns_resolver" "connectivity" {
  for_each = local.azurerm_private_dns_resolver_connectivity

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
    azurerm_resource_group.connectivity,
    azurerm_virtual_network.connectivity
  ]

}

resource "azurerm_private_dns_resolver_inbound_endpoint" "connectivity" {
  for_each = local.azurerm_private_dns_resolver_inbound_endpoint_connectivity

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
    azurerm_subnet.connectivity,
    azurerm_private_dns_resolver.connectivity,
  ]

}

resource "azurerm_private_dns_resolver_outbound_endpoint" "connectivity" {
  for_each = local.azurerm_private_dns_resolver_outbound_endpoint_connectivity

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
    azurerm_private_dns_resolver_inbound_endpoint.connectivity
  ]

}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "connectivity" {
  for_each = local.azurerm_private_dns_resolver_dns_forwarding_ruleset_connectivity

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
    azurerm_private_dns_resolver_outbound_endpoint.connectivity
  ]

}

resource "azurerm_private_dns_resolver_forwarding_rule" "connectivity" {
  for_each = local.azurerm_private_dns_resolver_forwarding_rule_connectivity

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
    azurerm_private_dns_resolver_dns_forwarding_ruleset.connectivity
  ]
}

resource "azurerm_dns_zone" "connectivity" {
  for_each = local.azurerm_dns_zone_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name

  # Optional resource attributes
  tags = each.value.template.tags

  # Dynamic configuration blocks
  dynamic "soa_record" {
    for_each = each.value.template.soa_record
    content {
      # Mandatory attributes
      email     = soa_record.value["email"]
      host_name = soa_record.value["host_name"]
      # Optional attributes
      expire_time   = try(soa_record.value["expire_time"], null)
      minimum_ttl   = try(soa_record.value["minimum_ttl"], null)
      refresh_time  = try(soa_record.value["refresh_time"], null)
      retry_time    = try(soa_record.value["retry_time"], null)
      serial_number = try(soa_record.value["serial_number"], null)
      ttl           = try(soa_record.value["ttl"], null)
      tags          = try(soa_record.value["tags"], each.value.template.tags)
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.connectivity,
  ]

}

resource "azurerm_private_dns_zone_virtual_network_link" "connectivity" {
  for_each = local.azurerm_private_dns_zone_virtual_network_link_connectivity

  provider = azurerm.connectivity

  # Mandatory resource attributes
  name                  = each.value.template.name
  resource_group_name   = each.value.template.resource_group_name
  private_dns_zone_name = each.value.template.private_dns_zone_name
  virtual_network_id    = each.value.template.virtual_network_id

  # Optional resource attributes
  registration_enabled = each.value.template.registration_enabled
  tags                 = each.value.template.tags

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.connectivity,
    azurerm_virtual_network.connectivity,
    azurerm_private_dns_zone.connectivity,
  ]

}

resource "azurerm_virtual_network_peering" "connectivity" {
  for_each = local.azurerm_virtual_network_peering_connectivity

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
    azurerm_resource_group.connectivity,
    azurerm_virtual_network.connectivity,
  ]
}
