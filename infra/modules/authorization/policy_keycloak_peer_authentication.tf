resource "kubernetes_manifest" "disable_peer_keycloak" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "disable-peer"
      namespace = var.NAMESPACE
    }
    spec = {
      selector = {
        matchLabels = {
          app = "keycloak"
        }
      }
      mtls = {
        mode = "PERMISSIVE"
      }
    }
  }
}
