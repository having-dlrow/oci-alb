# oci
variable "compartment_id" { default = "" }

# oci provider
variable "region" { default = "" }
variable "fingerprint" { default = "" }
variable "tenancy_ocid" { default = "" }
variable "user_ocid" { default = "" }
variable "private_key_path" { default = "" }

# instance
# Image Resource >>> ./module/instance/variable.tf
variable "ssh_private_key" {}
variable "ssh_public_key" {}
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

# network
variable "hostname" {
  type    = list(map(string))
  default = []
}
variable "vcn_cidr_block" {
  default = "192.168.1.0/16"
}
variable "subnet_cidr_block" {
  default = "192.168.1.0/24"
}
variable "egress_security_rules" {
  description = "Egress security rules"
  type        = list(map(string))
  default     = []
}
variable "ingress_security_rules" {
  description = "Ingress security rules"
  type        = list(map(string))
  default     = []
}
variable "my_public_ip" {}

# cloudflare
variable "cloudflare_zone_id" {}  # Cloudflare Zone ID
variable "cloudflare_api_token" { # Cloudflare Token
  sensitive = true
  default   = ""
}

# docker 
variable "docker_secret_key" {}
