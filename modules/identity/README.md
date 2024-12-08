<!-- BEGIN_TF_DOCS -->
# Identity sub-module

## Documentation
<!-- markdownlint-disable MD033 -->

## Requirements

No requirements.

## Modules

No modules.

<!-- markdownlint-disable MD013 -->
<!-- markdownlint-disable MD034 -->
## Required Inputs

The following input variables are required:

### <a name="input_enabled"></a> [enabled](#input\_enabled)

Description: Controls whether to manage the identity landing zone policies and deploy the identity resources into the current Subscription context.

Type: `bool`

### <a name="input_root_id"></a> [root\_id](#input\_root\_id)

Description: Specifies the ID of the Enterprise-scale root Management Group, used as a prefix for resources created by this module.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_settings"></a> [settings](#input\_settings)

Description: Configuration settings for the "Identity" landing zone resources.

Type:

```hcl
object({
    identity = optional(object({
      enabled = optional(bool, true)
      config = optional(object({
          key_vault      = optional(object({
            purge_protection_enabled = optional(bool, true)
          }), {})
      }), {})
    }), {})
    adds  = optional(list(
      object({
        identifier                  = optional(string, "")
        enabled                     = optional(bool, false)
        vnet_identifier             = optional(string, "")
        subnet_identifier           = optional(string, "")
        location                    = optional(string, "")
        config                      = object({
          vms = optional(list(
            object({
              vm_name_prefix              = optional(string, "")
              size                        = optional(string, "")
              provision_vm_agent          = optional(bool, true)
              admin_username              = optional(string, "")
              key_vault_secret            = optional(string, "")
              encryption_at_host_enabled  = optional(bool, false)
              publisher                   = optional(string, "")
              offer                       = optional(string, "")
              sku                         = optional(string, "")
              version                     = optional(string, "")
            })
          ), [])
       })
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
  })
```

Default: `{}`

## Resources

No resources.

## Outputs

The following outputs are exported:

### <a name="output_configuration"></a> [configuration](#output\_configuration)

Description: Returns the configuration settings for resources to deploy for the identity solution.

<!-- markdownlint-enable -->

<!-- END_TF_DOCS -->
