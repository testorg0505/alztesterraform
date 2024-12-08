# The following variables are used to determine the archetype
# definition to use and create the required resources.
#
# Further information provided within the description block
# for each variable

variable "enabled" {
  type        = bool
  description = "Controls whether to manage the landing zone policies and deploy the landing zone resources into the current Subscription context."
}

variable "root_id" {
  type        = string
  description = "Specifies the ID of the Enterprise-scale root Management Group, used as a prefix for resources created by this module."

  validation {
    condition     = can(regex("[a-zA-Z0-9-_\\(\\)\\.]", var.root_id))
    error_message = "Value must consist of alphanumeric characters and hyphens."
  }
}

variable "tenant_id" {
  type        = string
  description = "Organization Tenant ID."
  default     = ""

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.tenant_id)) || var.tenant_id == ""
    error_message = "Value must be a valid Tenant ID (GUID)."
  }
}

variable "subscription_id" {
  type        = string
  description = "Specifies the Subscription ID for the Subscription containing all management resources."

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.subscription_id)) || var.subscription_id == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "location" {
  type        = string
  description = "Sets the default location used for resource deployments where needed."
  # I would normally make this a variable and list what the variable is in the main main.tf
  # This will allow us to deploy to both AE and ASE without needing to change the variables
  default = "australiaeast"
}

variable "tags" {
  type        = map(string)
  description = "If specified, will set the default tags for all resources deployed by this module where supported."
  default     = {}
}

variable "resource_type_names" {
  type        = any
  description = <<DESCRIPTION
  type = object({
    organization           = optional(string, "")
    resource_group         = optional(string, "arg")
    virtual_network        = optional(string, "vnt")
    virtual_wan            = optional(string, "vwan")
    vwan_hub               = optional(string, "vhub")
    express_route_gateway  = optional(string, "erg")
    express_route_circuit  = optional(string, "erc")
    network_security_group = optional(string, "nsg")
    virtual_network        = optional(string, "vnt")
    vpn_gateway            = optional(string, "vng")
    route_table            = optional(string, "udr")
    key_vault              = optional(string, "akv")
    recovery_vault         = optional(string, "rsv")
    log_analytics          = optional(string, "law")
    azure_automation       = optional(string, "aaa")
    storage_account        = optional(string, "sta")
    azure_bastion          = optional(string, "bas")
    azure_firewall         = optional(string, "afw")
    azure_firewall_policy  = optional(string, "afp")
    public_ip              = optional(string, "pip")
    azure_ddos             = optional(string, "ddos")
    container_registry     = optional(string, "acr")
  })

  DESCRIPTION
}

variable "settings" {
  type = object({
    landingzones = optional(object({
      enabled = optional(bool, true)
      config = optional(object({
        amount                            = optional(number, 500)
        start_date                        = optional(string, "")
        end_date                          = optional(string, "")
        subscription_name                 = optional(string, "")
        enable_notifications              = optional(bool, true)
        threshold                         = optional(string, "")
        operator                          = optional(string, "")
        action_group_name                 = optional(string, "")
        action_group_shortname            = optional(string, "")
        contact_email                     = optional(string, "")
      }), {})
    }), {})
    rbac = optional(list(
      object({
        role_definition_id = optional(string, "")
        principal_id       = optional(string, "")
      })
    ), [])
    spoke_networks  = optional(list(
      object({
        identifier  = optional(string, "")
        enabled     = optional(bool, true)
        config      = object({
          address_space                = list(string)
          location                     = optional(string, "")
          link_to_ddos_protection_plan = optional(bool, false)
          dns_servers                  = optional(list(string), [])
          subnets = optional(list(
            object({
              name                          = string
              address_prefixes              = list(string)
              bgp_route_propagation_enabled = optional(bool, true)
              rules = optional(list(
                object({
                  name                          = optional(string, "")
                  priority                      = optional(number, 100)
                  direction                     = optional(string, "")
                  access                        = optional(string, "")
                  protocol                      = optional(string, "")
                  source_port_range             = optional(string, "")
                  source_port_ranges            = optional(list(string), [])
                  destination_port_range        = optional(string, "")
                  destination_port_ranges       = optional(list(string), [])
                  source_address_prefix         = optional(string, "")
                  source_address_prefixes       = optional(list(string), [])
                  destination_address_prefix    = optional(string, "")
                  destination_address_prefixes  = optional(list(string), [])
                })
              ), [])
              routes = optional(list(
                object({
                  name                    = optional(string, "")
                  address_prefix          = optional(string, "")
                  next_hop_type           = optional(string, "")
                  next_hop_in_ip_address  = optional(string, null)
                })
              ), [])
              delegations = optional(list(
                object({
                  name                = optional(string, "")
                  service_delegation  = optional(list(
                    object({
                      name    = optional(string, "")
                      actions = optional(list(string), [])
                    })
                  ), [])
                })
              ), [])
              service_endpoints   = optional(list(string), [])
            })
          ), [])
          hub_network_id                = optional(string, "")
          allow_virtual_network_access  = optional(bool, true)
          allow_forwarded_traffic       = optional(bool, true)
          use_remote_gateways           = optional(bool, false)
        })
      })
    ), [])
  })
  description = "Configuration settings for the landing zone resources."
  default     = {}
}


variable "resource_prefix" {
  type        = string
  description = "If specified, will set the resource name prefix for management resources (default value determined from \"var.root_id\")."
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,10}$", var.resource_prefix)) || var.resource_prefix == ""
    error_message = "Value must be between 2 to 10 characters long, consisting of alphanumeric characters and hyphens."
  }
}

variable "resource_suffix" {
  type        = string
  description = "If specified, will set the resource name suffix for management resources."
  default     = ""

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,36}$", var.resource_suffix)) || var.resource_suffix == ""
    error_message = "Value must be between 2 to 36 characters long, consisting of alphanumeric characters and hyphens."
  }

}

variable "custom_azure_backup_geo_codes" {
  type        = map(string)
  description = <<DESCRIPTION
If specified, the custom_azure_backup_geo_codes variable will override or append Geo Codes (value) used to generate region-specific DNS zone names for Azure Backup private endpoints.
For more information, please refer to: https://learn.microsoft.com/azure/backup/private-endpoints#when-using-custom-dns-server-or-host-files
DESCRIPTION
  default     = {}
}

variable "custom_settings_by_resource_type" {
  type        = any
  description = "If specified, allows full customization of common settings for all resources (by type) deployed by this module."
  default     = {}

  validation {
    condition     = can([for k in keys(var.custom_settings_by_resource_type) : contains(["azurerm_resource_group", "azurerm_log_analytics_workspace", "azurerm_log_analytics_solution", "azurerm_automation_account", "azurerm_log_analytics_linked_service"], k)]) || var.custom_settings_by_resource_type == {}
    error_message = "Invalid key specified. Please check the list of allowed resource types supported by the management module for caf-enterprise-scale."
  }
}

variable "subscription_id_landingzones" {
  type        = string
  description = "If specified, identifies the subscription for landing zone resource deployment and correct placement in the Management Group hierarchy."
  default     = ""

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.subscription_id_landingzones)) || var.subscription_id_landingzones == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}



