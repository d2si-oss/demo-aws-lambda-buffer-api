variable "method" {
  type        = "string"
  description = "HTTP method"
  default     = "GET"
}

variable "rest_api_id" {
  type        = "string"
  description = "ID of the rest API"
}

variable "parent_id" {
  type        = "string"
  description = "ID of the rest API"
}

variable "resource_part" {
  type        = "string"
  description = "uri of the resource relative to the parent"
}

variable "api_key_required" {
  default     = "false"
  description = "Whether the segment requires API Key authorization or not"
}

variable "region" {}
variable "allowed_account_id" {}
variable "function_name" {}
