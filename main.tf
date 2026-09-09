resource "azurerm_cdn_frontdoor_firewall_policy" "this" {
  resource_group_name = coalesce(
    var.cdn_frontdoor_firewall_policy.resource_group_name, var.resource_group_name
  )

  name                                      = var.cdn_frontdoor_firewall_policy.name
  sku_name                                  = var.cdn_frontdoor_firewall_policy.sku_name
  enabled                                   = var.cdn_frontdoor_firewall_policy.enabled
  mode                                      = var.cdn_frontdoor_firewall_policy.mode
  redirect_url                              = var.cdn_frontdoor_firewall_policy.redirect_url
  custom_block_response_status_code         = var.cdn_frontdoor_firewall_policy.custom_block_response_status_code
  custom_block_response_body                = var.cdn_frontdoor_firewall_policy.custom_block_response_body
  request_body_check_enabled                = var.cdn_frontdoor_firewall_policy.request_body_check_enabled
  captcha_cookie_expiration_in_minutes      = var.cdn_frontdoor_firewall_policy.captcha_cookie_expiration_in_minutes
  js_challenge_cookie_expiration_in_minutes = var.cdn_frontdoor_firewall_policy.js_challenge_cookie_expiration_in_minutes

  tags = coalesce(
    var.cdn_frontdoor_firewall_policy.tags, var.tags
  )

  dynamic "log_scrubbing" {
    for_each = var.cdn_frontdoor_firewall_policy.log_scrubbing != null ? { "this" = var.cdn_frontdoor_firewall_policy.log_scrubbing } : {}

    content {
      enabled = log_scrubbing.value.enabled

      dynamic "scrubbing_rule" {
        for_each = log_scrubbing.value.scrubbing_rules

        content {
          enabled        = scrubbing_rule.value.enabled
          match_variable = scrubbing_rule.value.match_variable
          operator       = scrubbing_rule.value.operator
          selector       = scrubbing_rule.value.selector
        }
      }
    }
  }

  dynamic "custom_rule" {
    for_each = var.cdn_frontdoor_firewall_policy.custom_rules

    content {
      name                           = custom_rule.value.name
      type                           = custom_rule.value.type
      priority                       = custom_rule.value.priority
      action                         = custom_rule.value.action
      enabled                        = custom_rule.value.enabled
      rate_limit_threshold           = custom_rule.value.rate_limit_threshold
      rate_limit_duration_in_minutes = custom_rule.value.rate_limit_duration_in_minutes

      dynamic "match_condition" {
        for_each = custom_rule.value.match_conditions

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
    for_each = var.cdn_frontdoor_firewall_policy.managed_rules

    content {
      type    = managed_rule.value.type
      version = managed_rule.value.version
      action  = managed_rule.value.action

      dynamic "exclusion" {
        for_each = managed_rule.value.exclusions

        content {
          match_variable = exclusion.value.match_variable
          operator       = exclusion.value.operator
          selector       = exclusion.value.selector
        }
      }

      dynamic "override" {
        for_each = managed_rule.value.overrides

        content {
          rule_group_name = override.value.rule_group_name

          dynamic "exclusion" {
            for_each = override.value.exclusions

            content {
              match_variable = exclusion.value.match_variable
              operator       = exclusion.value.operator
              selector       = exclusion.value.selector
            }
          }

          dynamic "rule" {
            for_each = override.value.rules

            content {
              rule_id = rule.key
              action  = rule.value.action
              enabled = rule.value.enabled

              dynamic "exclusion" {
                for_each = rule.value.exclusions

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

resource "azurerm_cdn_frontdoor_security_policy" "this" {
  for_each = var.cdn_frontdoor_firewall_policy.security_policy != null ? { "policy" = var.cdn_frontdoor_firewall_policy.security_policy } : {}

  name                     = each.value.name
  cdn_frontdoor_profile_id = var.cdn_frontdoor_firewall_policy.frontdoor_id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.this.id

      dynamic "association" {
        for_each = each.value.associations

        content {
          patterns_to_match = association.value.patterns_to_match

          dynamic "domain" {
            for_each = association.value.domains

            content {
              cdn_frontdoor_domain_id = domain.value.domain_id
            }
          }
        }
      }
    }
  }
}
