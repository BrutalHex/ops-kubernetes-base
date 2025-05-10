locals {
  keycloak_domain = "keycloak.${var.DOMAIN}"
}
resource "kubernetes_deployment" "keycloak" {
  depends_on = [kubernetes_stateful_set.postgresql]
  metadata {
    name      = "keycloak"
    namespace = var.NAMESPACE
    labels = {
      app = "keycloak"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "keycloak"
      }
    }

    template {
      metadata {
        labels = {
          app = "keycloak"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.keycloak-sa.metadata[0].name
        restart_policy       = "Always"

        container {
          name              = "keycloak"
          image             = "quay.io/keycloak/keycloak:26.2.4"
          image_pull_policy = "IfNotPresent"

          security_context {
            run_as_user  = 1000
            run_as_group = 3000
          }

          readiness_probe {
            http_get {
              path = "/realms/master"
              port = 8080
            }
          }

          port {
            name           = "keycloak-p1"
            container_port = 8080
          }
          command = [
            "/opt/keycloak/bin/kc.sh"
          ]

          args = [
            "start",
            "--http-enabled=true",
            "--https-port=-1",
            "--hostname-strict=false",
            "--proxy-headers=xforwarded",
          ]

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
          env {
            name  = "KC_HTTPS_PORT"
            value = ""
          }
          env {
            name  = "KC_HOSTNAME_STRICT"
            value = "false"
          }
          env {
            name  = "KC_HOSTNAME"
            value = local.keycloak_domain
          }
          env {
            name  = "KEYCLOAK_FRONTEND_URL"
            value = "http://${local.keycloak_domain}/auth"
          }
          env {
            name = "KC_BOOTSTRAP_ADMIN_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.keycloak-secret.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "KC_BOOTSTRAP_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.keycloak-secret.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "KC_PROXY"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak-configmap.metadata[0].name
                key  = "KC_PROXY"
              }
            }
          }

          env {
            name = "KC_DB"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak-configmap.metadata[0].name
                key  = "KC_DB"
              }
            }
          }

          env {
            name = "KC_DB_URL_HOST"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak-configmap.metadata[0].name
                key  = "KC_DB_URL_HOST"
              }
            }
          }

          env {
            name = "KC_DB_URL_PORT"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak-configmap.metadata[0].name
                key  = "KC_DB_URL_PORT"
              }
            }
          }

          env {
            name = "KC_DB_URL_DATABASE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak-configmap.metadata[0].name
                key  = "KC_DB_URL_DATABASE"
              }
            }
          }

          env {
            name = "KC_DB_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres-secret.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "KC_DB_SCHEMA"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak-configmap.metadata[0].name
                key  = "KC_DB_SCHEMA"
              }
            }
          }

          env {
            name = "KC_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres-secret.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "PROXY_ADDRESS_FORWARDING"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak-configmap.metadata[0].name
                key  = "PROXY_ADDRESS_FORWARDING"
              }
            }
          }

          env {
            name = "KEYCLOAK_LOGLEVEL"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak-configmap.metadata[0].name
                key  = "KEYCLOAK_LOGLEVEL"
              }
            }
          }

          env {
            name = "KC_FEATURES"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.keycloak-configmap.metadata[0].name
                key  = "KC_FEATURES"
              }
            }
          }
        }
      }
    }
  }
}
