resource "random_password" "keycloak-admin-password" {
  length  = 16
  special = true
}

locals {
  keycloak-ueser-name = "admin"
}

resource "kubernetes_secret" "keycloak-secret" {
  metadata {
    name      = "keycloak-admin-password"
    namespace = var.NAMESPACE
  }
  data = {
    username = local.keycloak-ueser-name
    password = random_password.keycloak-admin-password.result
  }
  type = "Opaque"
}
