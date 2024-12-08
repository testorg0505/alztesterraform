resource "azurerm_resource_group" "identity" {
  for_each = local.azurerm_resource_group_identity

  provider = azurerm.identity

  # Mandatory resource attributes
  name     = each.value.template.name
  location = each.value.template.location
  tags     = each.value.template.tags
}

resource "azurerm_virtual_network" "identity" {
  for_each = local.azurerm_virtual_network_identity

  provider = azurerm.identity

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
    azurerm_resource_group.identity,
  ]
}

resource "azurerm_subnet" "identity" {
  for_each = local.azurerm_subnet_identity

  provider = azurerm.identity

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
    azurerm_resource_group.identity,
    azurerm_virtual_network.identity,
  ]
}

resource "azurerm_network_security_group" "identity" {
  for_each = local.azurerm_network_security_group_identity

  provider = azurerm.identity

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
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.identity,
    azurerm_virtual_network.identity,
  ]
}

resource "azurerm_route_table" "identity" {
  for_each = local.azurerm_route_table_identity

  provider = azurerm.identity

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
    azurerm_resource_group.identity,
    azurerm_virtual_network.identity,
  ]
}

resource "azurerm_subnet_route_table_association" "identity" {
  for_each = local.azurerm_subnet_route_table_association_identity

  provider = azurerm.identity

  # Mandatory resource attributes
  subnet_id      = each.value.template.subnet_id
  route_table_id = each.value.template.route_table_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.identity,
    azurerm_subnet.identity,
    azurerm_route_table.identity,
  ]
}

resource "azurerm_subnet_network_security_group_association" "identity" {
  for_each = local.azurerm_subnet_network_security_group_association_identity

  provider = azurerm.identity

  # Mandatory resource attributes
  subnet_id                 = each.value.template.subnet_id
  network_security_group_id = each.value.template.network_security_group_id

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.identity,
    azurerm_subnet.identity,
    azurerm_network_security_group.identity,
  ]
}

resource "azurerm_virtual_network_peering" "identity" {
  for_each = local.azurerm_virtual_network_peering_identity

  provider = azurerm.identity

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
    azurerm_resource_group.identity,
    azurerm_virtual_network.identity,
  ]
}

resource "azurerm_key_vault" "identity" {
  for_each = local.azurerm_key_vault_identity

  provider = azurerm.identity

  # Mandatory resource attributes
  name                = each.value.template.name
  location            = each.value.template.location
  resource_group_name = each.value.template.resource_group_name

  # Optional resource attributes
  sku_name                  = each.value.template.sku_name
  tenant_id                 = each.value.template.tenant_id
  tags                      = each.value.template.tags
  purge_protection_enabled  = each.value.template.purge_protection_enabled
  enable_rbac_authorization = true


  # Set explicit dependency on Resource Group deployment
  depends_on = [
    azurerm_resource_group.identity,
  ]

}

# Generate VM local password
resource "random_password" "identity" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-=+[]{}<>:?"
}

# Create Key Vault Secret
resource "azurerm_key_vault_secret" "identity" {
  for_each = local.azurerm_key_vault_secret_identity

  provider = azurerm.identity

  name         = each.value.template.name
  value        = random_password.identity.result
  key_vault_id = each.value.template.key_vault_id
  content_type = each.value.template.content_type

  depends_on = [
    azurerm_key_vault.identity
  ]
}

# Create NIC
resource "azurerm_network_interface" "identity" {
  for_each = local.azurerm_network_interface_identity

  provider = azurerm.identity

  # Mandatory resource attributes
  name                = each.value.template.name
  resource_group_name = each.value.template.resource_group_name
  location            = each.value.template.location

  # Optional resource attributes
  accelerated_networking_enabled = each.value.template.accelerated_networking_enabled

  # Dynamic configuration blocks
  ip_configuration {
    name                          = "${each.value.template.ip_configuration.name}-ipconfig"
    subnet_id                     = each.value.template.ip_configuration.subnet_id
    private_ip_address_allocation = each.value.template.ip_configuration.private_ip_address_allocation
  }


  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.identity,
    azurerm_subnet.identity,
  ]
}

# Create Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "identity" {
  for_each = local.azurerm_windows_virtual_machine_identity

  provider = azurerm.identity

  # Mandatory resource attributes
  #count               = each.value.managed_by_module ? each.value.template.count : 0
  name                       = each.value.template.name
  resource_group_name        = each.value.template.resource_group_name
  location                   = each.value.template.location
  size                       = each.value.template.size
  network_interface_ids      = [each.value.template.network_interface_ids]
  provision_vm_agent         = each.value.template.provision_vm_agent
  admin_username             = each.value.template.admin_username
  admin_password             = azurerm_key_vault_secret.identity[each.value.template.admin_password].value
  encryption_at_host_enabled = each.value.template.encryption_at_host_enabled

  # Optional resource attributes
  tags = each.value.template.tags

  # Dynamic configuration blocks
  os_disk {
    name                 = "${each.value.template.name}-osdisk"
    caching              = each.value.template.os_disk.caching
    storage_account_type = each.value.template.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = each.value.template.source_image_reference.publisher
    offer     = each.value.template.source_image_reference.offer
    sku       = each.value.template.source_image_reference.sku
    version   = each.value.template.source_image_reference.version
  }

  # Set explicit dependencies
  depends_on = [
    azurerm_resource_group.identity,
    azurerm_network_interface.identity,
  ]
}
