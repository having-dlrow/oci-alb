# output "app_node" {
#   value = [for instance in oci_core_instance.app_node : instance.public_ip]
# }
output "app_node" {
  description = "List of app nodes with names and public IPs"
  value = [
    for instance in oci_core_instance.app_node :
    {
      name      = instance.display_name
      public_ip = instance.public_ip
    }
  ]
}

output "apps" {
  # value = "http://${data.oci_core_vnic.app_vnic.public_ip_address}"
  value = [for vnic in data.oci_core_vnic.app_vnic : "http://${vnic.public_ip_address}"]
}
