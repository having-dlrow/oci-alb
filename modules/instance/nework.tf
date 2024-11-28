/* application binding */

#### backend 1024 free
resource "oci_load_balancer_backend" "app_http_backend" {
  count            = var.instance_count
  backendset_name  = var.app_http_backend_set_name
  load_balancer_id = var.lb_id
  port             = 80
  ip_address       = oci_core_instance.app_node[count.index].private_ip
}

resource "oci_load_balancer_backend" "app_https_backend" {
  count            = var.instance_count
  backendset_name  = var.app_https_backend_set_name
  load_balancer_id = var.lb_id
  port             = 443
  ip_address       = oci_core_instance.app_node[count.index].private_ip
}


/* end of application binding */