variable "app_node" {}
variable "instance_count" {}

# https://registry.terraform.io/providers/cloudflare/cloudflare/4.46.0/docs/resources/record
data "cloudflare_zone" "zone_info" {
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "oci_a_record" {
  depends_on = [var.app_node]

  count = var.instance_count

  zone_id = var.cloudflare_zone_id
  name    = var.app_node[count.index].name
  type    = "A"
  content = var.app_node[count.index].public_ip
  ttl     = 1
  proxied = false
}
