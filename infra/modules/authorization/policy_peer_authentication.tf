resource "kubernetes_manifest" "peer_authentication" {
  manifest = {
    apiVersion = "security.istio.io/v1"
    kind       = "PeerAuthentication"
    metadata = {
      name      = "peer-auth"
      namespace = var.ISTIO_NAMESPACE
    }
    spec = {
      mtls = {
        mode = "STRICT"
      }
    }
  }
}