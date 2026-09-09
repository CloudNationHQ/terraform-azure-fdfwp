module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.32"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "policy" {
  source  = "cloudnationhq/fdfwp/azure"
  version = "~> 3.0"

  cdn_frontdoor_firewall_policy = {
    name                = module.naming.cdn_frontdoor_firewall_policy.name
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "Premium_AzureFrontDoor"
    managed_rules = {
      default_ruleset = {
        type    = "DefaultRuleSet"
        version = "1.0"
        action  = "Block"
      }
      bot_protection = {
        type    = "Microsoft_BotManagerRuleSet"
        version = "1.0"
        action  = "Block"
      }
    }
  }
}
