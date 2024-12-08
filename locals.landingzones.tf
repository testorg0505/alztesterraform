# The following locals are used to build the map of Resource
# Groups to deploy.
locals {
  azurerm_resource_group_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_resource_group :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Virtual
# Networks to deploy.
locals {
  azurerm_virtual_network_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_virtual_network :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Subnets
# to deploy.
locals {
  azurerm_subnet_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_subnet :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Network Security Groups
# to deploy.
locals {
  azurerm_network_security_group_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_network_security_group :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Route Tables
# to deploy.
locals {
  azurerm_route_table_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_route_table :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of subnet / Network Security Group associations 
# to deploy.
locals {
  azurerm_subnet_network_security_group_association_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_subnet_network_security_group_association :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of subnet / Route Table associations
# to deploy.
locals {
  azurerm_subnet_route_table_association_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_subnet_route_table_association :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Virtual
# Network Peerings to deploy.
locals {
  azurerm_virtual_network_peering_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_virtual_network_peering :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of action
# groups to deploy.
locals {
  azurerm_role_assignment_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_role_assignment :
    resource.resource_name => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of action
# groups to deploy.
locals {
  azurerm_monitor_action_group_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_monitor_action_group :
    resource.resource_name => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of the
# Subscription budget.
locals {
  azurerm_consumption_budget_subscription_landingzones = {
    for resource in module.landingzones_resources.configuration.azurerm_consumption_budget_subscription :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

