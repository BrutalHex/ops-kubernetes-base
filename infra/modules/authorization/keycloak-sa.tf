resource "kubernetes_service_account" "keycloak-sa" {
  metadata {
    name      = "keycloak-sa"
    namespace = var.NAMESPACE
  }
}
