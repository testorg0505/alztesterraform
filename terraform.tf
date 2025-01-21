# Configure the minimum required providers supported by this module
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.16.0"
      # version = ">= 3.54.0"
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.management,
        azurerm.identity,
        azurerm.landingzones,
      ]
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }

  required_version = ">= 1.10.4"

  backend "azurerm" {
    resource_group_name  = "terraform-state-arg"
    storage_account_name = "tfstate3839"
    container_name       = "tfstatecontainer"
    key                  = "terraform.tfstate"
    subscription_id      = "4f747eb9-ea78-44ce-ac5a-f4dc4085645a"
  }
}

provider "azurerm" {
  skip_provider_registration = "true"
  subscription_id = local.subscription_id_connectivity
  features {}
}

provider "azurerm" {
  skip_provider_registration = "true"
  subscription_id            = local.subscription_id_connectivity
  features {}
  alias = "connectivity"
}

provider "azurerm" {
  skip_provider_registration = "true"
  subscription_id            = local.subscription_id_management
  features {}
  alias = "management"
}

provider "azurerm" {
  skip_provider_registration = "true"
  subscription_id            = local.subscription_id_identity
  features {}
  alias = "identity"
}

provider "azurerm" {
  skip_provider_registration = "true"
  subscription_id            = local.subscription_id_landingzones
  features {}
  alias = "landingzones"
}
