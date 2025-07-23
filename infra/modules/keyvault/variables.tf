variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "object_id" {
  description = "The object ID of the current user/service principal"
  type        = string
}

variable "backend_identity_principal_id" {
  description = "Principal ID of the backend managed identity"
  type        = string
  default     = null
}
