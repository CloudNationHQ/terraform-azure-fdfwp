# Default

This example illustrates the default setup, in its simplest form.

## Types


```hcl
type = object({
  name           = string
  resource_group = string
  sku_name       = optional(string)
  managed_rules = optional(map(object({
    type    = string
    version = string
    action  = optional(string)
  })))
})
```
