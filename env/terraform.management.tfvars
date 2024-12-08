
deploy_core_landing_zones   = false
deploy_corp_landing_zones   = false
deploy_online_landing_zones = false

deploy_connectivity_resources = false
deploy_identity_resources     = false
deploy_management_resources   = true
deploy_landingzones_resources = false

# Configure the management resources settings.
configure_management_resources = {
  settings = {
    log_analytics = {
      enabled = true
      config = {
        retention_in_days                                 = 90
        enable_monitoring_for_vm                          = true
        enable_monitoring_for_vmss                        = true
        enable_solution_for_agent_health_assessment       = true
        enable_solution_for_anti_malware                  = true
        enable_solution_for_change_tracking               = true
        enable_solution_for_service_map                   = false
        enable_solution_for_sql_assessment                = false
        enable_solution_for_sql_vulnerability_assessment  = false
        enable_solution_for_sql_advanced_threat_detection = false
        enable_solution_for_updates                       = true
        enable_solution_for_vm_insights                   = true
        enable_solution_for_container_insights            = true
        enable_sentinel                                   = false
      }
    }

    spoke_networks = [
      {
        identifier = "vnet_australiaeast"
        enabled    = true
        config = {
          address_space                = ["10.112.16.0/20", ]
          location                     = "australiaeast"
          link_to_ddos_protection_plan = false
          dns_servers                  = []
          subnets = [
            {
              name                          = "Management"
              address_prefixes              = ["10.112.16.0/24"]
              bgp_route_propagation_enabled = false
              routes = []
              rules = [
                {
                  name                       = "AllowInbound"
                  priority                   = 100
                  direction                  = "Inbound"
                  access                     = "Allow"
                  protocol                   = "*"
                  source_port_range          = "*"
                  destination_port_range     = "*"
                  source_address_prefix      = "VirtualNetwork"
                  destination_address_prefix = "VirtualNetwork"
                },
                {
                  name                       = "AllowOutbound"
                  priority                   = 100
                  direction                  = "Outbound"
                  access                     = "Allow"
                  protocol                   = "*"
                  source_port_range          = "*"
                  destination_port_range     = "*"
                  source_address_prefix      = "VirtualNetwork"
                  destination_address_prefix = "VirtualNetwork"
                }
              ]
              delegations       = []
              service_endpoints = []
            }
          ]
          hub_network_id               = "/subscriptions/fa90f629-7323-4b3f-aee4-1362cdd64a2e/resourceGroups/arg-testhubvnet/providers/Microsoft.Network/virtualNetworks/vnt-test-hub"
          allow_virtual_network_access = true
          allow_forwarded_traffic      = true
          use_remote_gateways          = false
        }
      },
      {
        identifier = "vnet_australiasoutheast"
        enabled    = true
        config = {
          address_space                = ["10.120.16.0/20", ]
          location                     = "australiasoutheast"
          link_to_ddos_protection_plan = false
          dns_servers                  = []
          subnets = [
            {
              name                          = "Management"
              address_prefixes              = ["10.120.16.0/24"]
              bgp_route_propagation_enabled = false
              routes = []
              rules = [
                {
                  name                       = "AllowInbound"
                  priority                   = 100
                  direction                  = "Inbound"
                  access                     = "Allow"
                  protocol                   = "*"
                  source_port_range          = "*"
                  destination_port_range     = "*"
                  source_address_prefix      = "VirtualNetwork"
                  destination_address_prefix = "VirtualNetwork"
                },
                {
                  name                       = "AllowOutbound"
                  priority                   = 100
                  direction                  = "Outbound"
                  access                     = "Allow"
                  protocol                   = "*"
                  source_port_range          = "*"
                  destination_port_range     = "*"
                  source_address_prefix      = "VirtualNetwork"
                  destination_address_prefix = "VirtualNetwork"
                }
              ]
              delegations       = []
              service_endpoints = []
            }
          ]
          hub_network_id               = "/subscriptions/fa90f629-7323-4b3f-aee4-1362cdd64a2e/resourceGroups/arg-testhubvnet/providers/Microsoft.Network/virtualNetworks/vnt-test-hub"
          allow_virtual_network_access = true
          allow_forwarded_traffic      = true
          use_remote_gateways          = false
        }
      }
    ]
    action_group_name       = "platformActionGroup"
    action_group_shortname  = "platActnGrp"
    contact_email           = "core.systems@apj.com.au"
  }

  location = "australiaeast"
  tags = {
    applicationName    = "Platform Management"
    contactEmail       = "core.systems@apj.com.au"
    costCenter         = "3973"
    criticality        = "Tier0"
    dataClassification = "Internal"
    owner              = "apj"
    environment        = "Production"
  }
  advanced = {
    resource_prefix = "plt-mgt"
    custom_azure_backup_geo_codes = {
      australiaeast      = "syd"
      australiasoutheast = "mel"
    }
  }
}
