# Custom Rules

This deploys custom rules on frontdoor firewall policy.

```hcl
type = object({
  name           = string
  resource_group = string
  sku_name       = optional(string)
  policy = optional(object({
    mode = string
  }))
  custom_rules = optional(map(object({
    name                           = string
    priority                       = number
    type                          = string
    action                        = string
    enabled                       = optional(bool)
    rate_limit_threshold          = optional(number)
    rate_limit_duration_in_minutes = optional(number)
    match_conditions = map(object({
      match_variable = string
      operator       = string
      match_values   = list(string)
    }))
  })))
})
```
