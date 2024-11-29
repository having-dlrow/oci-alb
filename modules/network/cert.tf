resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "ca" {
  # key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  subject {
    common_name         = "Self Signed CA"
    organization        = "Self Signed"
    organizational_unit = "na"
  }

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]

}

resource "tls_private_key" "lb_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_cert_request" "lb_cert_request" {
  # key_algorithm   = "RSA"
  private_key_pem = tls_private_key.lb_private_key.private_key_pem

  dns_names = ["localhost"]

  subject {
    common_name         = "cn"
    organization        = "org"
    country             = "country"
    organizational_unit = "ou"
  }

}

resource "tls_locally_signed_cert" "lb_cert" {
  cert_request_pem = tls_cert_request.lb_cert_request.cert_request_pem
  # ca_key_algorithm   = "RSA"
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]

}

### certificates 150 free
resource "oci_load_balancer_certificate" "load_balancer_certificate" {
  certificate_name = "app_lb_certificate"
  load_balancer_id = oci_load_balancer_load_balancer.app_load_balancer.id

  private_key        = tls_private_key.lb_private_key.private_key_pem
  public_certificate = tls_locally_signed_cert.lb_cert.cert_pem
  ca_certificate     = tls_self_signed_cert.ca.cert_pem

  # 자동갱신
  lifecycle {
    create_before_destroy = true
  }
}

