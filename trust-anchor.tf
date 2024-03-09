data "kubernetes_secret" "ca" {
  metadata {
    name      = var.cert_manager_trust_anchor_ca_secret_name
    namespace = var.cert_manager_namespace
  }
  binary_data = {
    "tls.crt" = "",
    "tls.key" = ""
  }
}

resource "aws_rolesanywhere_trust_anchor" "otterize-cert-manager-spiffe-ca" {
  name    = var.aws_rolesanywhere_trust_anchor_name
  enabled = true
  source {
    source_data {
      x509_certificate_data = data.kubernetes_secret.ca.data["ca.crt"]
    }
    source_type = "CERTIFICATE_BUNDLE"
  }
  tags = {
    "otterize/system"      = "true"
    "otterize/clusterName" = var.cluster_name
  }
}