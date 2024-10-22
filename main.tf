resource "azurerm_cdn_frontdoor_firewall_policy" "policy" {
  name                              = var.config.name
  resource_group_name               = coalesce(lookup(var.config, "resource_group", null), var.resource_group)
  sku_name                          = try(var.config.sku_name, "Standard_AzureFrontDoor")
  enabled                           = try(var.config.policy.enabled, true)
  mode                              = try(var.config.policy.mode, "Prevention")
  redirect_url                      = try(var.config.policy.redirect_url, null)
  custom_block_response_status_code = try(var.config.policy.custom_block_response_status_code, null)
  custom_block_response_body        = try(var.config.policy.custom_block_response_body, null)
  request_body_check_enabled        = try(var.config.policy.request_body_check_enabled, false)

  dynamic "custom_rule" {
    for_each = try(
      var.config.custom_rules, {}
    )

    content {
      type                           = custom_rule.value.type
      name                           = custom_rule.value.name
      priority                       = custom_rule.value.priority
      action                         = custom_rule.value.action
      enabled                        = try(custom_rule.value.enabled, true)
      rate_limit_threshold           = try(custom_rule.value.rate_limit_threshold, null)
      rate_limit_duration_in_minutes = try(custom_rule.value.rate_limit_duration_in_minutes, null)

      dynamic "match_condition" {
        for_each = try(
          custom_rule.value.match_conditions, {}
        )

        content {
          operator           = match_condition.value.operator
          selector           = try(match_condition.value.selector, null)
          transforms         = try(match_condition.value.transform, [])
          match_values       = match_condition.value.match_values
          match_variable     = match_condition.value.match_variable
          negation_condition = try(match_condition.value.negation_condition, false)
        }
      }
    }
  }

  dynamic "managed_rule" {
    for_each = try(
      var.config.managed_rules, {}
    )

    content {
      type    = managed_rule.value.type
      version = managed_rule.value.version
      action  = try(managed_rule.value.action, "Block")

      dynamic "exclusion" {
        for_each = try(
          managed_rule.value.exclusions, {}
        )

        content {
          match_variable = exclusion.value.match_variable
          operator       = exclusion.value.operator
          selector       = exclusion.value.selector
        }
      }

      dynamic "override" {
        for_each = try(
          managed_rule.value.overrides, {}
        )

        content {
          rule_group_name = override.value.rule_group_name

          dynamic "exclusion" {
            for_each = try(
              override.value.exclusions, {}
            )

            content {
              match_variable = exclusion.value.match_variable
              operator       = exclusion.value.operator
              selector       = exclusion.value.selector
            }
          }

          dynamic "rule" {
            for_each = try(
              override.value.rules, {}
            )

            content {
              rule_id = rule.key
              action  = rule.value.action
              enabled = try(rule.value.enabled, true)

              dynamic "exclusion" {
                for_each = try(
                  rule.value.exclusions, {}
                )

                content {
                  match_variable = exclusion.value.match_variable
                  operator       = exclusion.value.operator
                  selector       = exclusion.value.selector
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "policy" {
  for_each = lookup(var.config, "security_policy", {})

  name                     = each.value.name
  cdn_frontdoor_profile_id = var.config.frontdoor_id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.policy.id

      dynamic "association" {
        for_each = try(each.value.associations, {})
        content {
          patterns_to_match = association.value.patterns_to_match

          dynamic "domain" {
            for_each = try(association.value.domains, {})
            content {
              cdn_frontdoor_domain_id = domain.value.domain_id
            }
          }
        }
      }
    }
  }
}
