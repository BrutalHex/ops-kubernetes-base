resource "kubernetes_persistent_volume_claim" "postgresql_pvc" {
  metadata {
    name      = "data-postgresql"
    namespace = "keycloak-space"
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "gp2"
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    volume_mode = "Filesystem"
  }
}
