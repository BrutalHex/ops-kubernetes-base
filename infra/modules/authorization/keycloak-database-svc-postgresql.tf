resource "kubernetes_service" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = "keycloak-space"
  }
  spec {
    selector = {
      "app.kubernetes.io/component" = "primary"
      "app.kubernetes.io/instance"  = "postgresql"
      "app.kubernetes.io/name"      = "postgresql"
    }

    port {
      name        = "tcp-postgresql"
      port        = 5432
      target_port = "tcp-postgresql"
      protocol    = "TCP"
    }

    session_affinity = "None"
    type             = "ClusterIP"
  }
}
