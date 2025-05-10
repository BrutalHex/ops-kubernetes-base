resource "kubernetes_manifest" "keycloak_http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "keycloak-route"
      namespace = var.NAMESPACE
    }
    spec = {
      parentRefs = [
        {
          name      = var.GATEWAY_NAME
          namespace = var.ISTIO_NAMESPACE
        }
      ]
      hostnames = [
        local.keycloak_domain
      ]
      rules = [
        {
          backendRefs = [
            {
              name = "keycloak"
              port = 8080
            }
          ]
        }
      ]
    }
  }
}
