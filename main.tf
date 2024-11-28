module "oci-network" {
  source = "./modules/network"

  compartment_id = var.compartment_id

  hostname               = var.hostname
  vcn_cidr_block         = var.vcn_cidr_block
  subnet_cidr_block      = var.subnet_cidr_block
  egress_security_rules  = var.egress_security_rules
  ingress_security_rules = var.ingress_security_rules

  my_public_ip   = var.my_public_ip
  instance_count = var.instance_count
}

module "oci-instance" {
  source = "./modules/instance"

  compartment_id = var.compartment_id
  tenancy_ocid   = var.tenancy_ocid

  ssh_private_key   = var.ssh_private_key
  ssh_public_key    = var.ssh_public_key
  docker_secret_key = var.docker_secret_key
  instance_count    = var.instance_count

  # arg
  lb_id                      = module.oci-network.lb_id
  app_subnet_id              = module.oci-network.app_subnet_id
  app_http_backend_set_name  = module.oci-network.app_http_backend_set_name
  app_https_backend_set_name = module.oci-network.app_https_backend_set_name
}

module "cloudflare" {
  source = "./modules/cloudflare"

  cloudflare_zone_id   = var.cloudflare_zone_id
  cloudflare_api_token = var.cloudflare_api_token

  app_node       = module.oci-instance.app_node
  instance_count = var.instance_count
}

output "app_node" {
  value = module.oci-instance.app_node
}

output "apps" {
  value = module.oci-instance.apps
}
