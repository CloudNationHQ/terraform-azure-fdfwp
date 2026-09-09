moved {
  from = azurerm_cdn_frontdoor_firewall_policy.policy
  to   = azurerm_cdn_frontdoor_firewall_policy.this
}

moved {
  from = azurerm_cdn_frontdoor_security_policy.policy
  to   = azurerm_cdn_frontdoor_security_policy.this
}
