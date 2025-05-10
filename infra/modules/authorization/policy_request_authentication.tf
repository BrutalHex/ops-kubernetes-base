resource "kubernetes_manifest" "request_authentication" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "RequestAuthentication"
    metadata = {
      name      = "auth-request"
      namespace = var.ISTIO_NAMESPACE
    }
    spec = {
      jwtRules = [
        {
          forwardOriginalToken  = true
          issuer                = "https://${local.keycloak_domain}/realms/master"
          jwksUri               = "https://keycloak.go.walletpan.com/realms/master/protocol/openid-connect/certs"
          outputPayloadToHeader = "x-jwt-payload"
        }
      ]
    }
  }
}
