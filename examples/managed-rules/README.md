# Managed Rules

This deploys managed rules on frontdoor firewall policy.

```hcl
type = object({
  name           = string
  resource_group = string
  sku_name       = optional(string)
  policy = optional(object({
    mode = string
  }))
  managed_rules = optional(map(object({
    type    = string
    version = string
    action  = optional(string)
    overrides = optional(map(object({
      rule_group_name = string
      rules = optional(map(object({
        action  = string
        enabled = optional(bool)
      })))
      exclusions = optional(map(object({
        match_variable = string
        operator       = string
        selector      = string
      })))
    })))
    exclusions = optional(map(object({
      match_variable = string
      operator       = string
      selector      = string
    })))
  })))
})
```
