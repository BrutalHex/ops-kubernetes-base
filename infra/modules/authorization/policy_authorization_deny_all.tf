resource "kubernetes_manifest" "allow_nothing_policy" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "allow-nothing"
      namespace = var.ISTIO_NAMESPACE
    }
    spec = {
      targetRefs = [{
        kind  = "Gateway"
        group = "gateway.networking.k8s.io"
        name  = var.GATEWAY_NAME
      }]
      action = "ALLOW"
    }
  }
}