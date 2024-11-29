output "lb_id" {
  value = oci_load_balancer_load_balancer.app_load_balancer.id
}

output "lb_public_ip" {
  value = [for detail in oci_load_balancer_load_balancer.app_load_balancer.ip_address_details : detail.ip_address]
}

output "app_subnet_id" {
  value = oci_core_subnet.app_subnet.id
}

output "app_http_backend_set_name" {
  value = oci_load_balancer_backend_set.app_http_backend_set.name
}

output "app_https_backend_set_name" {
  value = oci_load_balancer_backend_set.app_https_backend_set.name
}

