# oci
variable "compartment_id" { default = "" }

# oci provider
# variable "region" { default = "" }
# variable "fingerprint" { default = "" }
# variable "tenancy_ocid" { default = "" }
# variable "user_ocid" { default = "" }
# variable "private_key_path" { default = "" }

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
  type    = list(map(string))
  default = []
}
variable "ingress_security_rules" {
  type    = list(map(string))
  default = []
}

variable "my_public_ip" {}
variable "instance_count" {
  type    = number
  default = 1
}
