
resource "kubernetes_manifest" "waypoint_gateway" {
  depends_on = [helm_release.istio-ztunnel]
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = var.GATEWAY_NAME
      namespace = kubernetes_namespace.istio-namespace.metadata[0].name
      annotations = {
        "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
        "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
        "service.beta.kubernetes.io/aws-load-balancer-ip-address-type" = "ipv4"
        "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
      }
    }
    spec = {
      gatewayClassName = "istio"
      listeners = [
        {
          name     = "https"
          port     = 443
          protocol = "HTTPS"
          tls = {
            mode = "Terminate"
            certificateRefs = [
              {
                kind      = "Secret"
                name      = "${var.DOMAIN}-tls"
                namespace = var.CERT_NAMESPACE
              }
            ]
          }
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        }
      ]
    }
  }
}