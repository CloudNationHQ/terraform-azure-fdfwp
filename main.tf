resource "azurerm_cdn_frontdoor_firewall_policy" "policy" {
  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  name                              = var.config.name
  sku_name                          = var.config.sku_name
  enabled                           = var.config.enabled
  mode                              = var.config.mode
  redirect_url                      = var.config.redirect_url
  custom_block_response_status_code = var.config.custom_block_response_status_code
  custom_block_response_body        = var.config.custom_block_response_body
  request_body_check_enabled        = var.config.request_body_check_enabled

  tags = coalesce(
    var.config.tags, var.tags
  )

  dynamic "custom_rule" {
    for_each = try(
      var.config.custom_rules, {}
    )

    content {
      name                           = custom_rule.value.name
      type                           = custom_rule.value.type
      priority                       = custom_rule.value.priority
      action                         = custom_rule.value.action
      enabled                        = custom_rule.value.enabled
      rate_limit_threshold           = custom_rule.value.rate_limit_threshold
      rate_limit_duration_in_minutes = custom_rule.value.rate_limit_duration_in_minutes

      dynamic "match_condition" {
        for_each = try(
          custom_rule.value.match_conditions, {}
        )

        content {
          operator           = match_condition.value.operator
          selector           = match_condition.value.selector
          transforms         = match_condition.value.transform
          match_values       = match_condition.value.match_values
          match_variable     = match_condition.value.match_variable
          negation_condition = match_condition.value.negation_condition
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
      action  = managed_rule.value.action

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
              enabled = rule.value.enabled

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
  for_each = lookup(var.config, "security_policy", null) != null ? { "policy" = var.config.security_policy } : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = var.config.frontdoor_id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.policy.id

      dynamic "association" {
        for_each = lookup(
          each.value, "associations", {}
        )

        content {
          patterns_to_match = association.value.patterns_to_match

          dynamic "domain" {
            for_each = lookup(
              association.value, "domains", {}
            )

            content {
              cdn_frontdoor_domain_id = domain.value.domain_id
            }
          }
        }
      }
    }
  }
}
