
resource "helm_release" "cert-manager" {
  depends_on = [helm_release.aws_ebs_csi_driver, helm_release.external-dns, kubernetes_namespace.namespace, helm_release.aws_load_balancer_controller]
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.SERVICE_ACCOUNT_NAME_CERT_MANAGER_NAMESPACE
  version    = "v1.17.1"
  values = [
    <<EOF
crds:
  enabled: false
  keep: false
replicaCount: 1
serviceAccount:
  create: false
  name: ${var.SERVICE_ACCOUNT_NAME_CERT_MANAGER}
EOF
  ]
}


resource "kubernetes_manifest" "letsencrypt_clusterissuer" {
  depends_on = [helm_release.aws_ebs_csi_driver, helm_release.external-dns, helm_release.cert-manager, kubernetes_namespace.namespace]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.CERT_EMAIL
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region       = var.AWS_REGION
                hostedZoneID = var.ROUTE53_ID
              }
            }
          }
        ]
      }
    }
  }
}
resource "kubernetes_manifest" "cert_wildcard" {
  depends_on = [helm_release.aws_ebs_csi_driver, helm_release.external-dns, helm_release.cert-manager, kubernetes_namespace.namespace]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "cert-wildcard"
      namespace = var.SERVICE_ACCOUNT_NAME_CERT_MANAGER_NAMESPACE
    }
    spec = {
      secretName = "${var.DOMAIN}-tls"
      issuerRef = {
        name = "letsencrypt"
        kind = "ClusterIssuer"
      }
      commonName = "*.${var.DOMAIN}"
      dnsNames = [
        "*.${var.DOMAIN}",
        "${var.DOMAIN}"
      ]
    }
  }
}

resource "kubernetes_manifest" "reference_grant" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1beta1"
    kind       = "ReferenceGrant"
    metadata = {
      name      = "allow-gateway-secret"
      namespace = var.SERVICE_ACCOUNT_NAME_CERT_MANAGER_NAMESPACE
    }
    spec = {
      from = [
        {
          group     = "gateway.networking.k8s.io"
          kind      = "Gateway"
          namespace = "istio-system"
        }
      ]
      to = [
        {
          group = ""
          kind  = "Secret"
          name  = "${var.DOMAIN}-tls" # Specific Secret
        }
      ]
    }
  }
}