resource "kubernetes_manifest" "keycloak-service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "keycloak"
      namespace = var.NAMESPACE
      labels = {
        service = "keycloak"
      }
    }
    spec = {
      selector = {
        app = "keycloak"
      }
      type = "ClusterIP"
      ports = [
        {
          name       = "http-hkeycloak1"
          port       = 8080
          targetPort = "keycloak-p1"
        }
      ]
    }
  }
}
