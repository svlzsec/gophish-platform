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
variable "enable_ses" {
  type    = bool
  default = false
}
variable "mail_domain" {
  type    = string
  default = ""
  validation {
    condition     = !var.enable_ses || length(var.mail_domain) > 0
    error_message = "mail_domain is required when enable_ses is true."
  }
}
variable "mail_from" {
  type    = string
  default = ""
  validation {
    condition     = !var.enable_ses || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.mail_from))
    error_message = "mail_from must be a valid address when enable_ses is true."
  }
}
variable "mail_smtp_port" {
  type    = number
  default = 587
  validation {
    condition     = var.mail_smtp_port == 465 || var.mail_smtp_port == 587
    error_message = "mail_smtp_port must be 465 or 587."
  }
}
