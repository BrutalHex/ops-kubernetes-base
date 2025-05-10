# This allows internal communications
resource "kubernetes_manifest" "auth_inner_policy" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "auth-whitelist"
      namespace = var.ISTIO_NAMESPACE
    }
    spec = {
      targetRefs = [{
        kind  = "Gateway"
        group = "gateway.networking.k8s.io"
        name  = var.GATEWAY_NAME
      }]
      action = "ALLOW"
      rules = [
        {
          from = [
            {
              source = {
                namespaces = var.WHITE_LISTED_NAMESPACES
              }
            }
          ]
        }
      ]
    }
  }
}
