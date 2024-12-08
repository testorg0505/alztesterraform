# The following variables are used to determine the archetype
# definition to use and create the required resources.
#
# Further information provided within the description block
# for each variable

variable "enabled" {
  type        = bool
  description = "Controls whether to manage the management landing zone policies and deploy the management resources into the current Subscription context."
}

variable "root_id" {
  type        = string
  description = "Specifies the ID of the Enterprise-scale root Management Group, used as a prefix for resources created by this module."

  validation {
    condition     = can(regex("[a-zA-Z0-9-_\\(\\)\\.]", var.root_id))
    error_message = "Value must consist of alphanumeric characters and hyphens."
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
  default     = "australiaeast"
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
    log_analytics = optional(object({
      enabled = optional(bool, true)
      config = optional(object({
        retention_in_days                                 = optional(number, 30)
        enable_monitoring_for_vm                          = optional(bool, true)
        enable_monitoring_for_vmss                        = optional(bool, true)
        enable_solution_for_agent_health_assessment       = optional(bool, true)
        enable_solution_for_anti_malware                  = optional(bool, true)
        enable_solution_for_change_tracking               = optional(bool, true)
        enable_solution_for_service_map                   = optional(bool, true)
        enable_solution_for_sql_assessment                = optional(bool, true)
        enable_solution_for_sql_vulnerability_assessment  = optional(bool, true)
        enable_solution_for_sql_advanced_threat_detection = optional(bool, true)
        enable_solution_for_updates                       = optional(bool, true)
        enable_solution_for_vm_insights                   = optional(bool, true)
        enable_solution_for_container_insights            = optional(bool, true)
        enable_sentinel                                   = optional(bool, true)
      }), {})
    }), {})
    security_center = optional(object({
      enabled = optional(bool, true)
      config = optional(object({
        email_security_contact                                = optional(string, "security_contact@replace_me")
        enable_defender_for_apis                              = optional(bool, true)
        enable_defender_for_app_services                      = optional(bool, true)
        enable_defender_for_arm                               = optional(bool, true)
        enable_defender_for_containers                        = optional(bool, true)
        enable_defender_for_cosmosdbs                         = optional(bool, true)
        enable_defender_for_cspm                              = optional(bool, true)
        enable_defender_for_dns                               = optional(bool, true)
        enable_defender_for_key_vault                         = optional(bool, true)
        enable_defender_for_oss_databases                     = optional(bool, true)
        enable_defender_for_servers                           = optional(bool, true)
        enable_defender_for_servers_vulnerability_assessments = optional(bool, true)
        enable_defender_for_sql_servers                       = optional(bool, true)
        enable_defender_for_sql_server_vms                    = optional(bool, true)
        enable_defender_for_storage                           = optional(bool, true)
      }), {})
    }), {})
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
                  name                        = optional(string, "")
                  priority                    = optional(number, 100)
                  direction                   = optional(string, "")
                  access                      = optional(string, "")
                  protocol                    = optional(string, "")
                  source_port_range           = optional(string, "")
                  destination_port_range      = optional(string, "")
                  source_address_prefix       = optional(string, "")
                  destination_address_prefix  = optional(string, "")
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
    action_group_name       = optional(string, "")
    action_group_shortname  = optional(string, "")
    contact_email           = optional(string, "")
  })
  description = "Configuration settings for the \"Management\" landing zone resources."
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

variable "existing_resource_group_name" {
  type        = string
  description = "If specified, module will skip creation of the management Resource Group and use existing."
  default     = ""
}

variable "existing_log_analytics_workspace_resource_id" {
  type        = string
  description = "If specified, module will skip creation of Log Analytics workspace and use existing."
  default     = ""
}

variable "existing_automation_account_resource_id" {
  type        = string
  description = "If specified, module will skip creation of Automation Account and use existing."
  default     = ""
}

variable "link_log_analytics_to_automation_account" {
  type        = bool
  description = "If set to true, module will link the Log Analytics workspace and Automation Account."
  default     = true
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

variable "asc_export_resource_group_name" {
  type        = string
  description = "If specified, will customise the `ascExportResourceGroupName` parameter for the `Deploy-MDFC-Config` Policy Assignment when managed by the module."
  default     = ""
}

variable "custom_azure_backup_geo_codes" {
  type        = map(string)
  description = <<DESCRIPTION
If specified, the custom_azure_backup_geo_codes variable will override or append Geo Codes (value) used to generate region-specific DNS zone names for Azure Backup private endpoints.
For more information, please refer to: https://learn.microsoft.com/azure/backup/private-endpoints#when-using-custom-dns-server-or-host-files
DESCRIPTION
  default     = {}
}
