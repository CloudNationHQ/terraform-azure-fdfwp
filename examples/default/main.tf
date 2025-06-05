module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

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
  version = "~> 2.0"

  config = {
    name                = module.naming.cdn_frontdoor_firewall_policy.name
    resource_group_name = module.rg.groups.demo.name
    sku_name            = "Premium_AzureFrontDoor"
    managed_rules = {
      default_ruleset = {
        type   = "DefaultRuleSet"
        action = "Block"
      }
      bot_protection = {
        type   = "Microsoft_BotManagerRuleSet"
        action = "Block"
      }
    }
  }
}
