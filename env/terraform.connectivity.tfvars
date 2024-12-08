# Needs to be updated based on the network design

deploy_core_landing_zones   = false
deploy_corp_landing_zones   = false
deploy_online_landing_zones = false

deploy_connectivity_resources = true
deploy_identity_resources     = false
deploy_management_resources   = false
deploy_landingzones_resources = false

# Configure the connectivity resources settings.
configure_connectivity_resources = {
  settings = {
    vwan_hub_networks = [
      {
        enabled = true
        config = {
          address_prefix                = "10.112.32.0/22"
          location                     = "australiaeast"
          sku            = ""
          routes         = []
          expressroute_gateway = {
              enabled = true
              config = {
                scale_unit = 1
              }
            }
          vpn_gateway = {
            enabled = false
            config = {
                bgp_settings       = []
                routing_preference = ""
                scale_unit         = 1
            }
          }
          azure_firewall = {
            enabled = true
            config = {
                enable_dns_proxy              = true
                dns_servers                   = []
                sku_tier                      = "Standard"
                base_policy_id                = ""
                private_ip_ranges             = []
                threat_intelligence_mode      = ""
                threat_intelligence_allowlist = []
                availability_zones = {
                  zone_1 = true
                  zone_2 = true
                  zone_3 = true
                }
            }
          }
          spoke_virtual_network_resource_ids = [] //spoke vnets to be peered with vwan hub
          secure_spoke_virtual_network_resource_ids = []
          enable_virtual_hub_connections            = true
        }
      },
      {
        enabled = false
        config = {
          address_prefix                = "10.112.64.0/22"
          location                     = "australiasoutheast"
          sku            = ""
          routes         = []
          expressroute_gateway = {
              enabled = false
              config = {
                scale_unit = 1
              }
            }
          vpn_gateway = {
            enabled = false
            config = {
                bgp_settings       = []
                routing_preference = ""
                scale_unit         = 1
            }
          }
          azure_firewall = {
            enabled = false
            config = {
                enable_dns_proxy              = true
                dns_servers                   = []
                sku_tier                      = "Standard"
                base_policy_id                = ""
                private_ip_ranges             = []
                threat_intelligence_mode      = ""
                threat_intelligence_allowlist = []
                availability_zones = {
                  zone_1 = true
                  zone_2 = true
                  zone_3 = true
                }
            }
          }
          spoke_virtual_network_resource_ids = []
          secure_spoke_virtual_network_resource_ids = []
          enable_virtual_hub_connections            = false
        }
      }
    ]
    ext_vwan_bastion_networks  = [
      {
        identifier = "vnet_australiaeast"
        enabled    = false
        config = {
          address_space                = ["10.112.38.0/24", ]
          location                     = "australiaeast"
          sku                          = "Basic"
          availability_zones = {
                zone_1 = true
                zone_2 = false
                zone_3 = false
          }
          link_to_ddos_protection_plan = false
          dns_servers                  = []
          subnets = [
            {
              name                          = "AzureBastionSubnet"
              address_prefixes              = ["10.112.38.0/24"]
              bgp_route_propagation_enabled = false
              rules = [
                {
                  name                       = "GatewayManager"
                  priority                   = 1001
                  direction                  = "Inbound"
                  access                     = "Allow"
                  protocol                   = "Tcp"
                  source_port_range          = "*"
                  destination_port_range     = "443"
                  source_address_prefix      = "GatewayManager"
                  destination_address_prefix = "*"
                },
                {
                  name                       = "Internet-Bastion-PublicIP"
                  priority                   = 1002
                  direction                  = "Inbound"
                  access                     = "Allow"
                  protocol                   = "Tcp"
                  source_port_range          = "*"
                  destination_port_range     = "443"
                  source_address_prefix      = "*"
                  destination_address_prefix = "*"
                },
                {
                  name                       = "OutboundVirtualNetwork"
                  priority                   = 1001
                  direction                  = "Outbound"
                  access                     = "Allow"
                  protocol                   = "Tcp"
                  source_port_range          = "*"
                  destination_port_ranges    = ["22","3389"]
                  source_address_prefix      = "*"
                  destination_address_prefix = "VirtualNetwork"
                },
                {
                  name                       = "OutboundToAzureCloud"
                  priority                   = 1002
                  direction                  = "Outbound"
                  access                     = "Allow"
                  protocol                   = "Tcp"
                  source_port_range          = "*"
                  destination_port_range     = "443"
                  source_address_prefix      = "*"
                  destination_address_prefix = "AzureCloud"
                }
              ]
              delegations       = []
              service_endpoints = []
            }
          ]
        }
      },
      {
        identifier = "vnet_australiasoutheast"
        enabled    = false
        config = {
          address_space                = ["10.112.70.0/24", ]
          location                     = "australiasoutheast"
         sku                           = "Basic"
          availability_zones = {
                zone_1 = false
                zone_2 = false
                zone_3 = false
        }
          link_to_ddos_protection_plan = false
          dns_servers                  = []
          subnets = [
            {
              name                          = "AzureBastionSubnet"
              address_prefixes              = ["10.112.70.0/24"]
              bgp_route_propagation_enabled = false
              rules = [
                {
                  name                       = "GatewayManager"
                  priority                   = 1001
                  direction                  = "Inbound"
                  access                     = "Allow"
                  protocol                   = "Tcp"
                  source_port_range          = "*"
                  destination_port_range     = "443"
                  source_address_prefix      = "GatewayManager"
                  destination_address_prefix = "*"
                },
                {
                  name                       = "Internet-Bastion-PublicIP"
                  priority                   = 1002
                  direction                  = "Inbound"
                  access                     = "Allow"
                  protocol                   = "Tcp"
                  source_port_range          = "*"
                  destination_port_range     = "443"
                  source_address_prefix      = "*"
                  destination_address_prefix = "*"
                },
                {
                  name                       = "OutboundVirtualNetwork"
                  priority                   = 1001
                  direction                  = "Outbound"
                  access                     = "Allow"
                  protocol                   = "Tcp"
                  source_port_range          = "*"
                  destination_port_ranges    = ["22","3389"]
                  source_address_prefix      = "*"
                  destination_address_prefix = "VirtualNetwork"
                },
                {
                  name                       = "OutboundToAzureCloud"
                  priority                   = 1002
                  direction                  = "Outbound"
                  access                     = "Allow"
                  protocol                   = "Tcp"
                  source_port_range          = "*"
                  destination_port_range     = "443"
                  source_address_prefix      = "*"
                  destination_address_prefix = "AzureCloud"
                }
              ]
              delegations       = []
              service_endpoints = []
            }
          ]
        }
      }
    ]
    ext_vwan_dnsresolver_networks  = [
      {
        enabled = true
        config = {
          address_space                = ["10.112.36.0/23", ]
          location                     = "australiaeast"
          address_prefix_in            =  "10.112.36.0/24"
          address_prefix_out           = "10.112.37.0/24"
          deploy_private_dns_resolver_inbound_endpoint       = true
          deploy_private_dns_resolver_outbound_endpoint      = true
          deploy_private_dns_resolver_dns_forwarding_ruleset = false
          private_dns_resolver_forwarding_rule = [
          /*{
             name = "dnsrule"
             domain_name = "string.com"
             target_dns_servers =  [
              {
               ip_address = "10.1.1.0"
               port = "25"
              }
             ]
             enabled = true
             metadata = {}
            }*/
         ]
          link_to_ddos_protection_plan = false
          dns_servers                  = []
        }
      },
      {
        enabled = false
        config = {
          address_space                = ["10.112.68.0/23", ]
          location                     = "australiasoutheast"
          address_prefix_in            =  "10.112.68.0/24"
          address_prefix_out           = "10.112.69.0/24"
          deploy_private_dns_resolver_inbound_endpoint       = true
          deploy_private_dns_resolver_outbound_endpoint      = true
          deploy_private_dns_resolver_dns_forwarding_ruleset = false
          private_dns_resolver_forwarding_rule = [
          /*{
             name = "dnsrule"
             domain_name = "string.com"
             target_dns_servers =  [
              {
               ip_address = "10.1.1.0"
               port = "25"
              }
             ]
             enabled = true
             metadata = {}
            }*/
         ]
          link_to_ddos_protection_plan = false
          dns_servers                  = []
        }
      }
   ]
    ddos_protection_plan = {
      enabled = false
      config = {
        location = "australiaeast"
      }
    }
    dns = {
      enabled = false
      config = {
        location = null
        enable_private_link_by_service = {
          azure_api_management                 = true
          azure_app_configuration_stores       = true
          azure_arc                            = true
          azure_automation_dscandhybridworker  = true
          azure_automation_webhook             = true
          azure_backup                         = true
          azure_batch_account                  = true
          azure_bot_service_bot                = true
          azure_bot_service_token              = true
          azure_cache_for_redis                = true
          azure_cache_for_redis_enterprise     = true
          azure_container_registry             = true
          azure_cosmos_db_cassandra            = true
          azure_cosmos_db_gremlin              = true
          azure_cosmos_db_mongodb              = true
          azure_cosmos_db_sql                  = true
          azure_cosmos_db_table                = true
          azure_databricks                     = true
          azure_data_explorer                  = true
          azure_data_factory                   = true
          azure_data_factory_portal            = true
          azure_data_health_data_services      = true
          azure_data_lake_file_system_gen2     = true
          azure_database_for_mariadb_server    = true
          azure_database_for_mysql_server      = true
          azure_database_for_postgresql_server = true
          azure_digital_twins                  = true
          azure_event_grid_domain              = true
          azure_event_grid_topic               = true
          azure_event_hubs_namespace           = true
          azure_file_sync                      = true
          azure_hdinsights                     = true
          azure_iot_dps                        = true
          azure_iot_hub                        = true
          azure_key_vault                      = true
          azure_key_vault_managed_hsm          = true
          azure_kubernetes_service_management  = true
          azure_machine_learning_workspace     = true
          azure_managed_disks                  = true
          azure_media_services                 = true
          azure_migrate                        = true
          azure_monitor                        = true
          azure_purview_account                = true
          azure_purview_studio                 = true
          azure_relay_namespace                = true
          azure_search_service                 = true
          azure_service_bus_namespace          = true
          azure_site_recovery                  = true
          azure_sql_database_sqlserver         = true
          azure_synapse_analytics_dev          = true
          azure_synapse_analytics_sql          = true
          azure_synapse_studio                 = true
          azure_web_apps_sites                 = true
          azure_web_apps_static_sites          = true
          cognitive_services_account           = true
          microsoft_power_bi                   = true
          signalr                              = true
          signalr_webpubsub                    = true
          storage_account_blob                 = true
          storage_account_file                 = true
          storage_account_queue                = true
          storage_account_table                = true
          storage_account_web                  = true
        }
        private_link_locations = [
          "australiaeast"
//          "australiasoutheast"
        ]
        public_dns_zones                                       = []
        private_dns_zones                                      = []
        enable_private_dns_zone_virtual_network_link_on_hubs   = true
        enable_private_dns_zone_virtual_network_link_on_spokes = true
        virtual_network_resource_ids_to_link                   = []
      }
    }
  }

  location = "australiaeast"
  tags = {
    applicationName    = "Platform Connectivity"
    contactEmail       = "network.support@apj.com.au"
    costCenter         = "3973"
    criticality        = "Tier0"
    dataClassification = "Internal"
    owner              = "apj"
    environment        = "Production"
  }
  advanced = {
    resource_prefix = "plt-con"
    custom_azure_backup_geo_codes = {
      australiaeast      = "syd"
      australiasoutheast = "mel"
    }
    custom_settings_by_resource_type = {
      azurerm_virtual_wan = {
        virtual_wan = {
          "australiaeast" = {
            allow_branch_to_branch_traffic    = false
          }
          # "australiasoutheast" = {
          #   allow_branch_to_branch_traffic    = false
          # }
        }
      }
    }
  }
}
