variable "app_node" {}
variable "lb_public_ip" {}
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

# @todo 나중에 map 만들어서 매칭해야할 듯
resource "cloudflare_record" "oci_keycloak_record" {
  depends_on = [var.app_node]

  zone_id = var.cloudflare_zone_id
  name    = "keycloak"
  type    = "A"
  content = var.lb_public_ip[0]
  ttl     = 1
  proxied = false
}
