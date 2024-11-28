resource "tls_private_key" "app" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "app" {
  private_key_pem = tls_private_key.app.private_key_pem

  subject {
    organization = "Oracle"
    country      = "KR"
    locality     = "Seoul"
    province     = "Seoul"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "cert_signing"
  ]

  is_ca_certificate = true
}

### certificates 150 free
resource "oci_load_balancer_certificate" "load_balancer_certificate" {
  load_balancer_id = oci_load_balancer_load_balancer.app_load_balancer.id
  certificate_name = "app_lb_certificate"

  ca_certificate     = tls_self_signed_cert.app.cert_pem
  public_certificate = tls_self_signed_cert.app.cert_pem
  private_key        = tls_private_key.app.private_key_pem

  # 자동갱신
  lifecycle {
    create_before_destroy = true
  }
}

