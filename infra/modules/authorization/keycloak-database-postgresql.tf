resource "kubernetes_stateful_set" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = "keycloak-space"
    labels = {
      "app.kubernetes.io/component" = "primary"
      "app.kubernetes.io/instance"  = "postgresql"
      "app.kubernetes.io/name"      = "postgresql"
    }
  }

  spec {
    service_name           = "postgresql"
    replicas               = 1
    pod_management_policy  = "OrderedReady"
    revision_history_limit = 10

    selector {
      match_labels = {
        "app.kubernetes.io/component" = "primary"
        "app.kubernetes.io/instance"  = "postgresql"
        "app.kubernetes.io/name"      = "postgresql"
      }
    }

    persistent_volume_claim_retention_policy {
      when_deleted = "Retain"
      when_scaled  = "Retain"
    }

    template {
      metadata {
        name = "postgresql"
        labels = {
          "app.kubernetes.io/component" = "primary"
          "app.kubernetes.io/instance"  = "postgresql"
          "app.kubernetes.io/name"      = "postgresql"
        }
      }

      spec {
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1
              pod_affinity_term {
                label_selector {
                  match_labels = {
                    "app.kubernetes.io/component" = "primary"
                    "app.kubernetes.io/instance"  = "postgresql"
                    "app.kubernetes.io/name"      = "postgresql"
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        automount_service_account_token  = false
        dns_policy                       = "ClusterFirst"
        restart_policy                   = "Always"
        scheduler_name                   = "default-scheduler"
        termination_grace_period_seconds = 30

        security_context {
          fs_group               = 1001
          fs_group_change_policy = "Always"
        }

        container {
          name              = "postgresql"
          image             = "docker.io/bitnami/postgresql:16.3.0-debian-12-r13"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "POSTGRESQL_PORT_NUMBER"
            value = "5432"
          }
          env {
            name  = "POSTGRESQL_VOLUME_DIR"
            value = "/bitnami/postgresql"
          }
          env {
            name  = "PGDATA"
            value = "/bitnami/postgresql/data"
          }
          env {
            name  = "POSTGRES_USER"
            value = "admin"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "postgres-admin-password"
                key  = "password"
              }
            }
          }
          env {
            name = "POSTGRES_POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "postgres-admin-password"
                key  = "password"
              }
            }
          }
          env {
            name  = "POSTGRES_DATABASE"
            value = "keycloak"
          }
          env {
            name  = "POSTGRESQL_ENABLE_LDAP"
            value = "no"
          }
          env {
            name  = "POSTGRESQL_ENABLE_TLS"
            value = "no"
          }
          env {
            name  = "POSTGRESQL_LOG_HOSTNAME"
            value = "false"
          }
          env {
            name  = "POSTGRESQL_LOG_CONNECTIONS"
            value = "false"
          }
          env {
            name  = "POSTGRESQL_LOG_DISCONNECTIONS"
            value = "false"
          }
          env {
            name  = "POSTGRESQL_PGAUDIT_LOG_CATALOG"
            value = "off"
          }
          env {
            name  = "POSTGRESQL_CLIENT_MIN_MESSAGES"
            value = "error"
          }
          env {
            name  = "POSTGRESQL_SHARED_PRELOAD_LIBRARIES"
            value = "pgaudit"
          }

          port {
            name           = "tcp-postgresql"
            container_port = 5432
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = true
            run_as_group               = 1001
            run_as_non_root            = true
            run_as_user                = 1001
            capabilities {
              drop = ["ALL"]
            }
            seccomp_profile {
              type = "RuntimeDefault"
            }
          }

          termination_message_path   = "/dev/termination-log"
          termination_message_policy = "File"

          volume_mount {
            name       = "empty-dir"
            mount_path = "/tmp"
            sub_path   = "tmp-dir"
          }
          volume_mount {
            name       = "empty-dir"
            mount_path = "/opt/bitnami/postgresql/conf"
            sub_path   = "app-conf-dir"
          }
          volume_mount {
            name       = "empty-dir"
            mount_path = "/opt/bitnami/postgresql/tmp"
            sub_path   = "app-tmp-dir"
          }
          volume_mount {
            name       = "dshm"
            mount_path = "/dev/shm"
          }
          volume_mount {
            name       = "data"
            mount_path = "/bitnami/postgresql"
          }
        }

        volume {
          name = "empty-dir"
          empty_dir {}
        }

        volume {
          name = "dshm"
          empty_dir {
            medium = "Memory"
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "data-postgresql"
          }
        }
      }
    }
  }
}
