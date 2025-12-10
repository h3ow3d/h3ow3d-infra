variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (production, staging, development)"
  type        = string
}

variable "google_client_id" {
  description = "Google OAuth 2.0 client ID"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth 2.0 client secret"
  type        = string
  sensitive   = true
}

variable "callback_urls" {
  description = "List of callback/logout URLs for the Cognito client"
  type        = list(string)
}

variable "domain_prefix" {
  description = "Domain prefix for the Cognito hosted UI (e.g. 'h3ow3d-auth')"
  type        = string
  default     = "h3ow3d-auth"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
