# Frontdoor Firewall Policy

This Terraform module simplifies azure frontdoor firewall and security policy management, offering flexible rule configuration, domain-based associations, and seamless integration with custom domains for enhanced security and scalability.

## Features

Flexible support for custom and managed rules.

Enables request body inspection

Allows custom response codes and redirect URLs

Integrates with frontdoor custom domains

Utilization of terratest for robust validation.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_cdn_frontdoor_firewall_policy.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_firewall_policy) (resource)
- [azurerm_cdn_frontdoor_security_policy.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_security_policy) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: contains frontdoor firewall and security policy configuration

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_firewall_policy"></a> [firewall\_policy](#output\_firewall\_policy)

Description: contains frontdoor firewall configuration

### <a name="output_security_policy"></a> [security\_policy](#output\_security\_policy)

Description: contains frontdoor security policy configuration
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-fdfwp/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-fdfwp" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/frontdoor/web-application-firewall)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/frontdoor/webapplicationfirewall/policies/)
