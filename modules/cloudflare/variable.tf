variable "cloudflare_zone_id" {}  # Cloudflare Zone ID
variable "cloudflare_api_token" { # Cloudflare Token
  sensitive = true
  default   = ""
}
