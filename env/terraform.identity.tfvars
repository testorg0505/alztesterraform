
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
              rules = [ //to be reviewed later
                # {
                #   name                       = "INBOUND-FROM-onPremisesADDS-TO-subnet-PORT-adServices-PROT-any-ALLOW" //'Inbound rules from on-premises ADDS servers to the subnet for the required ports and protocols'
                #   priority                   = 500
                #   direction                  = "Inbound"
                #   access                     = "Allow"
                #   protocol                   = "*"
                #   source_port_range          = "*"
                #   source_port_ranges         = []
                #   destination_port_range     = ""
                #   destination_port_ranges    = ["53", "88", "135", "389", "445", "464", "636", "3268-3269", "9389", "49152-65535"]
                #   source_address_prefix      = ""
                #   source_address_prefixes    = [""] ////On-Premises Active Directory Services IPs. Replace it with actual ranges
                #   destination_address_prefix = "10.112.0.0/24" // Platform Identity ADDS Subnet Range.
                # },
                # {
                #   name                       = "INBOUND-FROM-onPremisesCorpNetworks-TO-adds-PORT-aadServices-PROT-any-ALLOW" //' 'Allow on-premises corp virtual networks traffic to adds subnet on adservices ports''
                #   priority                   = 501
                #   direction                  = "Inbound"
                #   access                     = "Allow"
                #   protocol                   = "*"
                #   source_port_range          = "*"
                #   source_port_ranges         = []
                #   destination_port_range     = ""
                #   destination_port_ranges    = ["53", "88", "135", "389", "445", "464", "636", "3268-3269", "9389", "49152-65535"]
                #   source_address_prefix      = ""
                #   source_address_prefixes    = [""] //OnPremises Corporate networks. Replace it with actual ranges.
                #   destination_address_prefix = "10.112.0.0/24" // Platform Identity ADDS Subnet Range.
                # },
                # {
                #   name                       = "INBOUND-FROM-azureSupernet-TO-adds-PORT-aadServices-PROT-any-ALLOW" //Inbound rules from Azure Supernet to the ADDS subnet for the required ports and protocols
                #   priority                   = 502
                #   direction                  = "Inbound"
                #   access                     = "Allow"
                #   protocol                   = "*"
                #   source_port_range          = "*"
                #   source_port_ranges         = []
                #   destination_port_range     = ""
                #   destination_port_ranges    = ["53", "88", "135", "389", "445", "464", "636", "3268-3269", "9389", "49152-65535"]
                #   source_address_prefix      = ""
                #   source_address_prefixes    = [""] //OnPremises Corporate networks. Replace it with actual ranges.
                #   destination_address_prefix = "10.112.0.0/18" //Azure Supernet Range
                # },
                {
                  name                       = "INBOUND-FROM-AzureBastion-TO-azurePlatDCs-PORT-22-3389-PROT-any-ALLOW" //Inbound rule from Azure allowed network to azure Platform Domain Controllers on port 22, 3389 and any protocol
                  priority                   = 503
                  direction                  = "Inbound"
                  access                     = "Allow"
                  protocol                   = "*"
                  source_port_range          = "*"
                  source_port_ranges         = []
                  destination_port_range     = ""
                  destination_port_ranges    = ["3389","22"]
                  source_address_prefix      = ""
                  source_address_prefixes    = ["10.112.70.0/24"] //Remote Access Network Ranges- Bastion 
                  destination_address_prefix = "10.120.0.0/24"  //Platform Identity ADDS Subnet Range
                },
                {
                  name                       = "INBOUND-FROM-subnet-TO-subnet-PORT-any-PROT-any-ALLOW" //Inbound rule from the subnet to the subnet on any port and any protocol'
                  priority                   = 999
                  direction                  = "Inbound"
                  access                     = "Allow"
                  protocol                   = "*"
                  source_port_range          = "*"
                  source_port_ranges         = []
                  destination_port_range     = ""
                  destination_port_ranges    = []
                  source_address_prefix      = ""
                  source_address_prefixes    = ["10.120.0.0/24"] // Platform Identity ADDS Subnet Range
                  destination_address_prefix = "10.120.0.0/24" //Platform Identity ADDS Subnet Range
                },                                   
                {
                  name                       = "INBOUND-FROM-virtualNetwork-TO-virtualNetwork-PORT-any-PROT-Icmp-ALLOW" //Inbound rules from any to the subnet for ICMP
                  priority                   = 1000
                  direction                  = "Inbound"
                  access                     = "Allow"
                  protocol                   = "Icmp"
                  source_port_range          = "*"
                  source_port_ranges         = []
                  destination_port_range     = ""
                  destination_port_ranges    = []
                  source_address_prefix      = "VirtualNetwork"
                  source_address_prefixes    = [] 
                  destination_address_prefix = "VirtualNetwork" 
                  destinationAddressPrefixes = []
                },
                {
                  name                       = "INBOUND-FROM-any-TO-any-PORT-any-PROT-any-DENY" //Inbound default deny rule
                  priority                   = 4000
                  direction                  = "Inbound"
                  access                     = "Deny"
                  protocol                   = "*"
                  source_port_range          = "*"
                  source_port_ranges         = []
                  destination_port_range     = ""
                  destination_port_ranges    = []
                  source_address_prefix      = "*"
                  source_address_prefixes    = [] 
                  destination_address_prefix = "*" 
                  destinationAddressPrefixes = []
                },
                {
                  name                       = "OUTBOUND-FROM-subnet-TO-any-PORT-443-PROT-Tcp-ALLOW" //Outbound rules from the subnet to Any for port 443'
                  priority                   = 1000
                  direction                  = "Outbound"
                  access                     = "Allow"
                  protocol                   = "Tcp"
                  source_port_range          = "*"
                  source_port_ranges         = []
                  destination_port_range     = "443"
                  destination_port_ranges    = []
                  source_address_prefix      = "*"
                  source_address_prefixes    = [] 
                  destination_address_prefix = "*" 
                  destinationAddressPrefixes = []
                },
                {
                  name                       = "OUTBOUND-FROM-any-TO-any-PORT-any-PROT-any-DENY" //Outboud default deny rule
                  priority                   = 4000
                  direction                  = "Outbound"
                  access                     = "Deny"
                  protocol                   = "*"
                  source_port_range          = "*"
                  source_port_ranges         = []
                  destination_port_range     = ""
                  destination_port_ranges    = []
                  source_address_prefix      = "*"
                  source_address_prefixes    = [] 
                  destination_address_prefix = "*" 
                  destinationAddressPrefixes = []
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
    costCenter         = ""
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
