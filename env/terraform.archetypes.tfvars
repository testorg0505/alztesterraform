
deploy_core_landing_zones   = true
deploy_corp_landing_zones   = true
deploy_online_landing_zones = true

deploy_connectivity_resources = false
deploy_identity_resources     = false
deploy_management_resources   = false
deploy_landingzones_resources = false

/*
subscription_id_overrides = {
  landingzones-corp = [
    ""
  ]
}
*/

archetype_config_overrides = {
  root = {
    archetype_id = "es_root"
    access_control = {
      "[MG-apj] Security-Operations" = ["19dca186-53bb-490b-950d-7bd5dc8d41f8"]
    }
    parameters = {
    }
  }
  landingzones = {
   parameters = {
     /*
      Deploy-VM-Backup = {
        effect            = "deployIfNotExists"
        exclusionTagName  = "SkipAutoShutdown"
        exclusionTagValue = ["yes","no"]
      } */
    }
    enforcement_mode = {}
  }
  landingzones-corp = {
    parameters = {
    }
    enforcement_mode = {}
  }
  platform-identity = {
    parameters = {
     /* Append-UDR-Route = {
        nextHopIpAddress = "10.100.0.4"
      } */
    }
    enforcement_mode = {}
  }
  platform-management = {
    parameters = {
     /* Append-UDR-Route = {
        nextHopIpAddress = "10.100.0.4"
      }*/
    }
    enforcement_mode = {}
  }
}

// This can be used if any custom landing zone requirements.
custom_landing_zones = {
  mg-apj-sandboxes = {
    display_name               = "Sandboxes"
    parent_management_group_id = "mg-apj"
    subscription_ids           = ["2449a8e6-1269-42e6-93b8-8ff92ffd47ef","bb865465-d5ac-493f-b7f7-1723e2243365"]
    archetype_config = {
      archetype_id   = "es_sandboxes"
      parameters     = {}
      access_control = {}
    }
  }
}

# Configure the management resources settings.
# The advanced settings are required to calculate the log analytics resource id
configure_management_resources = {
  settings = {
    security_center = {
      enabled = true
      config = {
        email_security_contact                                = "core.systems@apj.com.au"
        enable_defender_for_apis                              = false
        enable_defender_for_app_services                      = false
        enable_defender_for_arm                               = false
        enable_defender_for_containers                        = false
        enable_defender_for_cosmosdbs                         = false
        enable_defender_for_cspm                              = false
        enable_defender_for_dns                               = false
        enable_defender_for_key_vault                         = false
        enable_defender_for_oss_databases                     = false
        enable_defender_for_servers                           = false
        enable_defender_for_servers_vulnerability_assessments = false
        enable_defender_for_sql_servers                       = false
        enable_defender_for_sql_server_vms                    = false
        enable_defender_for_storage                           = false
      }
    }
  action_group_name       = "platformActionGroup"
  }
  advanced = {
    asc_export_resource_group_name = "ascExportRG"
    resource_prefix = "plt-mgt"
    custom_azure_backup_geo_codes = {
      australiaeast      = "syd"
      australiasoutheast = "mel"
    }
  }
}
