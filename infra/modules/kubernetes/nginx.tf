resource "helm_release" "ingress-nginx" {
  depends_on = [
    helm_release.aws_ebs_csi_driver,
    helm_release.external-dns,
    kubernetes_namespace.namespace,
    helm_release.cert-manager,
    kubernetes_manifest.cert_wildcard
  ]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = var.NAMESPACES_NGINX
  version    = "4.12.0"
  values = [yamlencode({
    controller = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
          "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
          "service.beta.kubernetes.io/aws-load-balancer-ip-address-type" = "ipv4"
          "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
        }
      }
      extraArgs = {
        "default-ssl-certificate" = "${var.SERVICE_ACCOUNT_NAME_CERT_MANAGER_NAMESPACE}/${var.DOMAIN}-tls"
      }
      ingressClassResource = {
        name    = "nginx"
        enabled = true
        default = true
      }
    }
  })]
}