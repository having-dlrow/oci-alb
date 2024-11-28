
# oci_load_balancer_load_balancer (ALB)
resource "oci_load_balancer_load_balancer" "app_load_balancer" {
  compartment_id = var.compartment_id
  display_name   = "app_load_balancer"
  subnet_ids = [
    oci_core_subnet.app_subnet.id,
  ]

  shape = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = 10
    minimum_bandwidth_in_mbps = 10
  }
}

#### backendSet 16 free
resource "oci_load_balancer_backend_set" "app_http_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.app_load_balancer.id
  name             = "app_http_backend_set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = 80
    retries           = 3
    return_code       = 200
    timeout_in_millis = 3000
    url_path          = "/"
  }
}

resource "oci_load_balancer_backend_set" "app_https_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.app_load_balancer.id
  name             = "app_https_backend_set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = 443
    retries           = 3
    return_code       = 200
    timeout_in_millis = 3000
    url_path          = "/"
  }

  # session_persistence_configuration {
  #   cookie_name      = "lb-session1"
  #   disable_fallback = true
  # }
}

#### hostname 16 free
resource "oci_load_balancer_hostname" "app_hostname" {
  load_balancer_id = oci_load_balancer_load_balancer.app_load_balancer.id
  hostname         = var.hostname[0].hostname
  name             = var.hostname[0].name
}

#### Listener 16 free
# resource "oci_load_balancer_rule_set" "app_lb_rule_set" {
#   load_balancer_id = oci_load_balancer_load_balancer.app_load_balancer.id
#   name             = "app_lb_rule_set_name"

#   items {
#     action = "ADD_HTTP_REQUEST_HEADER"
#     header = "example_header_name"
#     value  = "example_header_value"
#   }

#   items {
#     action          = "CONTROL_ACCESS_USING_HTTP_METHODS"
#     allowed_methods = ["GET", "POST"]
#     status_code     = "405"
#   }
# }

resource "oci_load_balancer_listener" "nginx_http_listener" {
  default_backend_set_name = oci_load_balancer_backend_set.app_http_backend_set.name
  name                     = "nginx_HTTP_listener"
  load_balancer_id         = oci_load_balancer_load_balancer.app_load_balancer.id
  port                     = 80
  protocol                 = "TCP"

  # hostname_names         = [oci_load_balancer_hostname.app_hostname.name]
  # rule_set_names         = [oci_load_balancer_rule_set.app_lb_rule_set.name]
  connection_configuration {
    idle_timeout_in_seconds = "240"
  }
}

resource "oci_load_balancer_listener" "nginx_https_listener" {
  default_backend_set_name = oci_load_balancer_backend_set.app_https_backend_set.name
  name                     = "nginx_HTTPS_listener"
  load_balancer_id         = oci_load_balancer_load_balancer.app_load_balancer.id
  port                     = 443
  # protocol                 = "HTTP"
  protocol = "TCP"

  # ssl_configuration {
  #   certificate_name        = oci_load_balancer_certificate.load_balancer_certificate.certificate_name
  #   verify_peer_certificate = false
  # }
}
