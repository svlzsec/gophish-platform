aws_region            = "eu-west-1"
client_name           = "acme-corp"
campaign_name         = "security-awareness-2026"
campaign_domain       = "awareness.acme-corp.example"
admin_allowlist_cidrs = ["203.0.113.10/32"]
instance_size         = "t3.small"
scope_end             = "2026-09-22T00:00:00Z"
hosted_zone_id        = "Z000000000000EXAMPLE"
# Enable only after the approved sending domain and SES account are ready.
enable_ses     = false
mail_domain    = ""
mail_from      = ""
mail_smtp_port = 587
