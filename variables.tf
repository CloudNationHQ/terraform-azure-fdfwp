variable "config" {
  description = "contains frontdoor firewall and security policy configuration"
  type        = any
}

variable "resource_group" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
