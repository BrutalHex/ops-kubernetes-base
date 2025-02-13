resource "kubernetes_manifest" "cluster_autoscaler_sa" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "cluster-autoscaler"
      namespace = "kube-system"
      labels = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
      annotations = {
        "eks.amazonaws.com/role-arn" = var.CLUSTER_AUTOSCALER_ROLE
      }
    }
  }
}

resource "kubernetes_manifest" "cluster_autoscaler_clusterrole" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRole"
    metadata = {
      name = "cluster-autoscaler"
      labels = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
    }
    rules = [
      {
        apiGroups = [""]
        resources = ["events", "endpoints"]
        verbs     = ["create", "patch"]
      },
      {
        apiGroups = [""]
        resources = ["pods/eviction"]
        verbs     = ["create"]
      },
      {
        apiGroups = [""]
        resources = ["pods/status"]
        verbs     = ["update"]
      },
      {
        apiGroups     = [""]
        resources     = ["endpoints"]
        resourceNames = ["cluster-autoscaler"]
        verbs         = ["get", "update"]
      },
      {
        apiGroups = [""]
        resources = ["nodes"]
        verbs     = ["watch", "list", "get", "update"]
      },
      {
        apiGroups = [""]
        resources = [
          "namespaces",
          "pods",
          "services",
          "replicationcontrollers",
          "persistentvolumeclaims",
          "persistentvolumes"
        ]
        verbs = ["watch", "list", "get"]
      },
      {
        apiGroups = ["extensions"]
        resources = ["replicasets", "daemonsets"]
        verbs     = ["watch", "list", "get"]
      },
      {
        apiGroups = ["policy"]
        resources = ["poddisruptionbudgets"]
        verbs     = ["watch", "list"]
      },
      {
        apiGroups = ["apps"]
        resources = ["statefulsets", "replicasets", "daemonsets"]
        verbs     = ["watch", "list", "get"]
      },
      {
        apiGroups = ["storage.k8s.io"]
        resources = ["storageclasses", "csinodes", "csidrivers", "csistoragecapacities"]
        verbs     = ["watch", "list", "get"]
      },
      {
        apiGroups = ["batch", "extensions"]
        resources = ["jobs"]
        verbs     = ["get", "list", "watch", "patch"]
      },
      {
        apiGroups = ["coordination.k8s.io"]
        resources = ["leases"]
        verbs     = ["create"]
      },
      {
        apiGroups     = ["coordination.k8s.io"]
        resourceNames = ["cluster-autoscaler"]
        resources     = ["leases"]
        verbs         = ["get", "update"]
      }
    ]
  }
}
resource "kubernetes_manifest" "cluster_autoscaler_role" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "Role"
    metadata = {
      name      = "cluster-autoscaler"
      namespace = "kube-system"
      labels = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
    }
    rules = [
      {
        apiGroups = [""]
        resources = ["configmaps"]
        verbs     = ["create", "list", "watch"]
      },
      {
        apiGroups     = [""]
        resources     = ["configmaps"]
        resourceNames = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
        verbs         = ["delete", "get", "update", "watch"]
      }
    ]
  }
}

resource "kubernetes_manifest" "cluster_autoscaler_clusterrolebinding" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"
    metadata = {
      name = "cluster-autoscaler"
      labels = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "ClusterRole"
      name     = "cluster-autoscaler"
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "cluster-autoscaler"
        namespace = "kube-system"
      }
    ]
  }
}
resource "kubernetes_manifest" "cluster_autoscaler_rolebinding" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "RoleBinding"
    metadata = {
      name      = "cluster-autoscaler"
      namespace = "kube-system"
      labels = {
        "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
        "k8s-app"   = "cluster-autoscaler"
      }
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "Role"
      name     = "cluster-autoscaler"
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "cluster-autoscaler"
        namespace = "kube-system"
      }
    ]
  }
}
resource "kubernetes_manifest" "cluster_autoscaler_deployment" {
  depends_on = [helm_release.aws_ebs_csi_driver]
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "cluster-autoscaler"
      namespace = "kube-system"
      labels = {
        app = "cluster-autoscaler"
      }
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = "cluster-autoscaler"
        }
      }
      template = {
        metadata = {
          labels = {
            app = "cluster-autoscaler"
          }
          annotations = {
            "prometheus.io/scrape" = "true"
            "prometheus.io/port"   = "8085"
          }
        }
        spec = {
          priorityClassName = "system-cluster-critical"
          securityContext = {
            runAsNonRoot = true
            runAsUser    = 65534
            fsGroup      = 65534
          }
          serviceAccountName = "cluster-autoscaler"
          containers = [
            {
              name            = "cluster-autoscaler"
              image           = "registry.k8s.io/autoscaling/cluster-autoscaler:v1.30.1"
              imagePullPolicy = "Always"
              resources = {
                limits = {
                  cpu    = "100m"
                  memory = "600Mi"
                }
                requests = {
                  cpu    = "100m"
                  memory = "600Mi"
                }
              }
              command = [
                "./cluster-autoscaler",
                "--v=4",
                "--stderrthreshold=info",
                "--cloud-provider=aws",
                "--skip-nodes-with-local-storage=false",
                "--expander=least-waste",
                "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.APP_NAME}"
              ]
              volumeMounts = [
                {
                  name      = "ssl-certs"
                  mountPath = "/etc/ssl/certs/ca-certificates.crt"
                  readOnly  = true
                }
              ]
            }
          ]
          volumes = [
            {
              name = "ssl-certs"
              hostPath = {
                path = "/etc/ssl/certs/ca-bundle.crt"
              }
            }
          ]
        }
      }
    }
  }
}
