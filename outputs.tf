output "firewall_policy" {
  description = "contains frontdoor firewall configuration"
  value       = azurerm_cdn_frontdoor_firewall_policy.policy
}

output "security_policy" {
  description = "contains frontdoor security policy configuration"
  value       = azurerm_cdn_frontdoor_security_policy.policy
}
