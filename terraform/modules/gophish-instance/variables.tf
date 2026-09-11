variable "client_name" {
  type = string
}
variable "campaign_domain" {
  type = string
}
variable "campaign_name" {
  type = string
}
variable "admin_allowlist_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.admin_allowlist_cidrs) > 0 && alltrue([for c in var.admin_allowlist_cidrs : c != "0.0.0.0/0" && c != "::/0"])
    error_message = "The admin allowlist must be non-empty and cannot contain a public-any CIDR."
  }
}
variable "instance_size" {
  type    = string
  default = "t3.small"
}
variable "scope_end" {
  type = string
  validation {
    condition     = can(formatdate("YYYY-MM-DD'T'hh:mm:ssZ", var.scope_end))
    error_message = "scope_end must be RFC3339."
  }
}
variable "hosted_zone_id" {
  type = string
}
variable "gophish_image" {
  type    = string
  default = "gophish/gophish:0.12.1"
}
variable "secret_names" {
  type    = set(string)
  default = ["api-key", "admin-password"]
}
