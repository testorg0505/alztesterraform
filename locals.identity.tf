# The following locals are used to build the map of Resource
# Groups to deploy.
locals {
  azurerm_resource_group_identity = {
    for resource in module.identity_resources.configuration.azurerm_resource_group :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Virtual
# Networks to deploy.
locals {
  azurerm_virtual_network_identity = {
    for resource in module.identity_resources.configuration.azurerm_virtual_network :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Subnets
# to deploy.
locals {
  azurerm_subnet_identity = {
    for resource in module.identity_resources.configuration.azurerm_subnet :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Network Security Groups
# to deploy.
locals {
  azurerm_network_security_group_identity = {
    for resource in module.identity_resources.configuration.azurerm_network_security_group :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Route Tables
# to deploy.
locals {
  azurerm_route_table_identity = {
    for resource in module.identity_resources.configuration.azurerm_route_table :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of subnet / Network Security Group associations
# to deploy.
locals {
  azurerm_subnet_network_security_group_association_identity = {
    for resource in module.identity_resources.configuration.azurerm_subnet_network_security_group_association :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of subnet / Route Table associations
# to deploy.
locals {
  azurerm_subnet_route_table_association_identity = {
    for resource in module.identity_resources.configuration.azurerm_subnet_route_table_association :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Virtual
# Network Peerings to deploy.
locals {
  azurerm_virtual_network_peering_identity = {
    for resource in module.identity_resources.configuration.azurerm_virtual_network_peering :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Key
# Vaults to deploy.
locals {
  azurerm_key_vault_identity = {
    for resource in module.identity_resources.configuration.azurerm_key_vault :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Azure Key
# Vault Secrets to deploy.
locals {
  azurerm_key_vault_secret_identity = {
    for resource in module.identity_resources.configuration.azurerm_key_vault_secret :
    resource.resource_name => resource
    if resource.managed_by_module
  }
}

locals {
  azurerm_network_interface_identity = {
    for resource in module.identity_resources.configuration.azurerm_network_interface :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}
locals {
  azurerm_windows_virtual_machine_identity = {
    for resource in module.identity_resources.configuration.azurerm_windows_virtual_machine :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}
