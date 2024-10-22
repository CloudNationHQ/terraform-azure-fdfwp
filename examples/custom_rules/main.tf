module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "policy" {
  source  = "cloudnationhq/fdfwp/azure"
  version = "~> 1.0"

  config = {
    name           = module.naming.cdn_frontdoor_firewall_policy.name
    resource_group = module.rg.groups.demo.name
    sku_name       = "Premium_AzureFrontDoor"

    policy = {
      mode = "Prevention"
    }

    custom_rules = {
      rate_limit = {
        name                           = "RateLimitRule"
        priority                       = 1
        type                           = "RateLimitRule"
        action                         = "Block"
        enabled                        = true
        rate_limit_threshold           = 1000
        rate_limit_duration_in_minutes = 1
        match_conditions = {
          all_requests = {
            match_variable = "RequestUri"
            operator       = "Any"
            match_values   = []
          }
        }
      }
      block_ip_ranges = {
        name     = "BlockIPRanges"
        priority = 2
        type     = "MatchRule"
        action   = "Block"
        match_conditions = {
          ip_ranges = {
            match_variable = "RemoteAddr"
            operator       = "IPMatch"
            match_values   = ["203.0.113.0/24", "198.51.100.0/24"]
          }
        }
      }
    }
  }
}
