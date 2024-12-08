# The following locals are used to build the map of Resource
# Groups to deploy.
locals {
  azurerm_resource_group_extended_vwan = {
    for resource in module.connectivity_resources.configuration.azurerm_resource_group :
    resource.resource_id => resource
    if resource.managed_by_module &&
    contains(["extended_vwan", "extended_vwan_dns"], resource.scope)
  }
}

# The following locals are used to build the map of Virtual
# Networks to deploy.
locals {
  azurerm_virtual_network_bastion = {
    for resource in module.connectivity_resources.configuration.azurerm_virtual_network_bastion :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Subnets
# to deploy.
locals {
  azurerm_ext_vwan_bastion_subnet = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_vwan_bastion_subnet :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Network Security Groups
# to deploy.
locals {
  azurerm_ext_vwan_bastion_nsg = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_vwan_bastion_nsg :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of subnet / Network Security Group associations
# to deploy.
locals {
  azurerm_ext_vwan_bastion_network_security_group_association = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_vwan_bastion_network_security_group_association :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

/*
# The following locals are used to build the map of Virtual
# Network Peerings to deploy.
locals {
  azurerm_ext_vwan_bastion_virtual_network_peering = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_vwan_bastion_virtual_network_peering :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}
*/

# The following locals are used to build the map of Bastion
# Hosts to deploy.
locals {
  azurerm_ext_vwan_bastion_host = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_vwan_bastion_host :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

/*
# The following locals are used to build the map of Public
# IPs to deploy.
locals {
  azurerm_public_ip_connectivity = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_vwan_public_ip :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}*/

# The following locals are used to build the map of Virtual
# Network Peerings to deploy.
/*locals {
  azurerm_ext_virtual_hub_connection = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_virtual_hub_connection :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}*/


# The following locals are used to build the map of Virtual
# Networks to deploy.
locals {
  azurerm_virtual_network_dns = {
    for resource in module.connectivity_resources.configuration.azurerm_virtual_network_dns :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Subnets
# to deploy.
locals {
  azurerm_ext_vwan_dns_subnet = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_vwan_dns_subnet :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

/*
# The following locals are used to build the map of Network Security Groups
# to deploy.
locals {
  azurerm_ext_vwan_dns_nsg = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_vwan_dns_nsg :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of subnet / Network Security Group associations
# to deploy.
locals {
  azurerm_ext_vwan_dns_network_security_group_association = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_vwan_bastion_network_security_group_association :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}*/
# The following locals are used to build the map of subnet / Route Table associations
# to deploy.
/*locals {
  azurerm_subnet_route_table_association_connectivity = {
    for resource in module.connectivity_resources.configuration.azurerm_subnet_route_table_association :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}*/

# The following locals are used to build the map of Private
# DNS Resolvers to deploy.
locals {
  azurerm_ext_private_dns_resolver_connectivity = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_private_dns_resolver :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Private
# DNS Resolvers Inbound Endpoints to deploy.
locals {
  azurerm_ext_private_dns_resolver_inbound_endpoint_connectivity = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_private_dns_resolver_inbound_endpoint :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Private
# DNS Resolvers Outbound Endpoints to deploy.
locals {
  azurerm_ext_private_dns_resolver_outbound_endpoint_connectivity = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_private_dns_resolver_outbound_endpoint :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Private
# DNS Resolvers Forwarding Rulesets to deploy.
locals {
  azurerm_ext_private_dns_resolver_dns_forwarding_ruleset_connectivity = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_private_dns_resolver_dns_forwarding_ruleset :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}

# The following locals are used to build the map of Private
# DNS Resolvers Forwarding Rules to deploy.
locals {
  azurerm_ext_private_dns_resolver_forwarding_rule_connectivity = {
    for resource in module.connectivity_resources.configuration.azurerm_ext_private_dns_resolver_forwarding_rule :
    resource.resource_id => resource
    if resource.managed_by_module
  }
}
