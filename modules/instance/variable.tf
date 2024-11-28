# oci
variable "compartment_id" { default = "" }
variable "tenancy_ocid" { default = "" }

# instance
variable "imageOS" { default = "Canonical Ubuntu" }
variable "imageOSVersion" { default = "24.04" }
variable "instance_shape" { default = "VM.Standard.A1.Flex" }  # VM.Standard.E2.1.Micro
variable "instance_shape_config_memory_in_gbs" { default = 6 } # VM.Standard.E2.1.Micro
variable "instance_ocpus" { default = 1 }

variable "ssh_private_key" {}
variable "ssh_public_key" {}
variable "instance_count" {}

# argument
variable "lb_id" {}
variable "app_subnet_id" {}
variable "app_http_backend_set_name" {}
variable "app_https_backend_set_name" {}

# docker 
variable "docker_secret_key" {}
