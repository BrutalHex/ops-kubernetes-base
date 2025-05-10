resource "kubernetes_manifest" "keycloak_external_service_entry" {
  manifest = {
    apiVersion = "networking.istio.io/v1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "keycloak-internal"
      namespace = var.ISTIO_NAMESPACE
    }
    spec = {
      hosts    = [local.keycloak_domain]
      location = "MESH_INTERNAL"
      ports = [
        {
          number   = 80
          name     = "http"
          protocol = "HTTP"
        }
      ]
      resolution = "DNS"
      endpoints = [
        {
          address = "keycloak.${var.NAMESPACE}.svc.cluster.local"
          ports = {
            http = 8080
          }
        }
      ]
    }
  }
}
