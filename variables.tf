variable "config" {
  description = "contains frontdoor firewall and security policy configuration"
  type = object({
    name                                      = string
    frontdoor_id                              = optional(string)
    resource_group_name                       = optional(string)
    sku_name                                  = optional(string, "Standard_AzureFrontDoor")
    tags                                      = optional(map(string))
    enabled                                   = optional(bool, true)
    mode                                      = optional(string, "Prevention")
    redirect_url                              = optional(string)
    custom_block_response_status_code         = optional(number)
    custom_block_response_body                = optional(string)
    request_body_check_enabled                = optional(bool, true)
    captcha_cookie_expiration_in_minutes      = optional(number)
    js_challenge_cookie_expiration_in_minutes = optional(number)
    log_scrubbing = optional(object({
      enabled = optional(bool, true)
      scrubbing_rules = optional(map(object({
        enabled        = optional(bool, true)
        match_variable = string
        operator       = optional(string, "Equals")
        selector       = optional(string)
      })), {})
    }))
    custom_rules = optional(map(object({
      type                           = string
      name                           = string
      priority                       = number
      action                         = string
      enabled                        = optional(bool, true)
      rate_limit_threshold           = optional(number)
      rate_limit_duration_in_minutes = optional(number)
      match_conditions = optional(map(object({
        operator           = string
        match_values       = list(string)
        match_variable     = string
        selector           = optional(string)
        transform          = optional(list(string), [])
        negation_condition = optional(bool, false)
      })), {})
    })), {})
    managed_rules = optional(map(object({
      type    = string
      version = string
      action  = optional(string, "Block")
      exclusions = optional(map(object({
        match_variable = string
        operator       = string
        selector       = string
      })), {})
      overrides = optional(map(object({
        rule_group_name = string
        exclusions = optional(map(object({
          match_variable = string
          operator       = string
          selector       = string
        })), {})
        rules = optional(map(object({
          action  = string
          enabled = optional(bool, true)
          exclusions = optional(map(object({
            match_variable = string
            operator       = string
            selector       = string
          })), {})
        })), {})
      })), {})
    })), {})
    security_policy = optional(object({
      name = string
      associations = optional(map(object({
        patterns_to_match = list(string)
        domains = optional(map(object({
          domain_id = string
        })), {})
      })), {})
    }))
  })

  validation {
    condition     = var.config.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the object or as a separate variable."
  }
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
