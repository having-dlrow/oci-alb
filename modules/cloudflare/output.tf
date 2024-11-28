output "cloudflare_records" {
  value = {
    instance0 = "https://keycloak.${data.cloudflare_zone.zone_info.name}"
    instance1 = "https://master.${var.cloudflare_zone_id}"
  }
}
