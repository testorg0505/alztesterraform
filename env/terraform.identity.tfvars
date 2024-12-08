
deploy_core_landing_zones   = false
deploy_corp_landing_zones   = false
deploy_online_landing_zones = false

deploy_connectivity_resources = false
deploy_identity_resources     = true
deploy_management_resources   = false
deploy_landingzones_resources = false

# Configure the identity resources settings.
configure_identity_resources = {
  settings = {
    identity = {
      enabled = true
      config = {
        key_vault = {
          purge_protection_enabled = true
        }
      }
    }
    adds = [
      {
        identifier                 = "adds_australiaeast"
        enabled                    = true
        vnet_identifier            = "vnet_australiaeast"
        subnet_identifier          = "identity"
        location                   = "australiaeast"
        config = {
          vms = [
            {
              vm_name_prefix             = "azaddssyd01"
              size                       = "Standard_D2s_v3"
              provision_vm_agent         = true
              admin_username             = "localAdminUser"
              key_vault_secret           = "vmlocalpassword"
              encryption_at_host_enabled = false
              publisher                  = "MicrosoftWindowsServer"
              offer                      = "WindowsServer"
              sku                        = "2022-datacenter-azure-edition"
              version                    = "latest"
            },
            {
              vm_name_prefix             = "azaddssyd02"
              size                       = "Standard_D2s_v3"
              provision_vm_agent         = true
              admin_username             = "localAdminUser"
              key_vault_secret           = "vmlocalpassword"
              encryption_at_host_enabled = false
              publisher                  = "MicrosoftWindowsServer"
              offer                      = "WindowsServer"
              sku                        = "2022-datacenter-azure-edition"
              version                    = "latest"
            }
          ]
        }
      },
      {
        identifier                 = "adds_australiasoutheast"
        enabled                    = true
        vnet_identifier            = "vnet_australiasoutheast"
        subnet_identifier          = "identity"
        location                   = "australiasoutheast"
        config = {
          vms = [
            {
              vm_name_prefix             = "azaddsmel01"
              size                       = "Standard_D2s_v3"
              provision_vm_agent         = true
              admin_username             = "localAdminUser"
              key_vault_secret           = "vmlocalpassword"
              encryption_at_host_enabled = false
              publisher                  = "MicrosoftWindowsServer"
              offer                      = "WindowsServer"
              sku                        = "2022-datacenter-azure-edition"
              version                    = "latest"
            },
            {
              vm_name_prefix             = "azaddsmel02"
              size                       = "Standard_D2s_v3"
              provision_vm_agent         = true
              admin_username             = "localAdminUser"
              key_vault_secret           = "vmlocalpassword"
              encryption_at_host_enabled = false
              publisher                  = "MicrosoftWindowsServer"
              offer                      = "WindowsServer"
              sku                        = "2022-datacenter-azure-edition"
              version                    = "latest"
            }
          ]
        }
      }
    ]
    spoke_networks = [
      {
        identifier = "vnet_australiaeast"
        enabled    = true
        config = {
          address_space                = ["10.112.0.0/20", ]
          location                     = "australiaeast"
          link_to_ddos_protection_plan = false
          dns_servers                  = []
          subnets = [
            {
              name                          = "identity"
              address_prefixes              = ["10.112.0.0/24"]
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
          allow_virtual_network_access = true
          allow_forwarded_traffic      = true
          use_remote_gateways          = false
        }
      },
      {
        identifier = "vnet_australiasoutheast"
        enabled    = true
        config = {
          address_space                = ["10.120.0.0/20", ]
          location                     = "australiasoutheast"
          link_to_ddos_protection_plan = false
          dns_servers                  = []
          subnets = [
            {
              name                          = "identity"
              address_prefixes              = ["10.120.0.0/24"]
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
          allow_virtual_network_access = true
          allow_forwarded_traffic      = true
          use_remote_gateways          = false
        }
      }
    ]
  }

  location = "australiaeast"
  tags = {
    applicationName    = "Platform Identity"
    contactEmail       = "core.systems@apj.com.au"
    costCenter         = "3973"
    criticality        = "Tier0"
    dataClassification = "Internal"
    owner              = "apj"
    environment        = "Production"
  }
  advanced = {
    resource_prefix = "plt-idm"
    custom_azure_backup_geo_codes = {
      australiaeast      = "syd"
      australiasoutheast = "mel"
    }
  }
}
