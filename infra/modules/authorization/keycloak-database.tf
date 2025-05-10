resource "random_password" "postgres-admin-password" {
  length  = 16
  special = true
}

locals {
  postgres-ueser-name = "admin"
}

resource "kubernetes_secret" "postgres-secret" {
  metadata {
    name      = "postgres-admin-password"
    namespace = var.NAMESPACE
  }
  data = {
    username = local.postgres-ueser-name
    password = random_password.postgres-admin-password.result
  }
  type = "Opaque"
}
