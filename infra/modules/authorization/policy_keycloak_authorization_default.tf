resource "kubernetes_manifest" "auth_login_policy" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "AuthorizationPolicy"
    metadata = {
      name      = "auth-login"
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
          to = [
            {
              operation = {
                hosts = [
                  "keycloak.${var.NAMESPACE}.svc.cluster.local",
                  local.keycloak_domain
                ]
              }
            }
          ]
        }
      ]
    }
  }
}
