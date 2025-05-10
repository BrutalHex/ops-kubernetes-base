locals {

  argocd_domain = "argocd.${var.DOMAIN}"
}

resource "helm_release" "argocd" {
  depends_on       = [helm_release.aws_load_balancer_controller, kubernetes_namespace.namespace]
  name             = var.ARGOCD_NAMESPACE
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.8.2"
  namespace        = var.ARGOCD_NAMESPACE
  create_namespace = false
  values = [yamlencode({
    crds = {
      install = false
    }
    global = {
      domain = local.argocd_domain
    }
    configs = {
      secret = {
        createSecret                   = true
        secretName                     = "argocd-secret"
        argocdServerAdminPassword      = replace(bcrypt(var.ARGOCD_ADMIN_PASSWORD, 10), "$2y$", "$2a$")
        argocdServerAdminPasswordMtime = timestamp()
      }
    }
    server = {
      extraArgs = ["--insecure"]
      params = {
        "server.insecure" = true
      }
      ingress = {
        extraTls = {}
        tls      = false
        enabled  = false
      }
      insecure    = true
      disableAuth = true
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }
    repoServer = {
      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          cpu    = "250m"
          memory = "256Mi"
        }
      }
    }
    controller = {
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }
    dex = {
      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          cpu    = "250m"
          memory = "256Mi"
        }
      }
    }
  })]
}

resource "kubernetes_manifest" "argocd_applicationset" {
  depends_on = [helm_release.argocd, kubernetes_namespace.namespace]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"
    metadata = {
      name      = "ops-argocd-apps"
      namespace = var.ARGOCD_NAMESPACE
    }
    spec = {
      goTemplate        = true
      goTemplateOptions = ["missingkey=error"]
      generators = [
        {
          git = {
            repoURL  = var.ARGOCD_APPS_REPOSITORY
            revision = "HEAD"
            files = [
              {
                path = "argocd-*.yaml"
              }
            ]
          }
        }
      ]
      template = {
        metadata = {
          name = "{{.metadata.name}}"
        }
        spec = {
          project = "default"
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "{{ .spec.destination.namespace }}"
          }
          source = {
            chart          = "{{ .spec.source.chart }}"
            repoURL        = "{{ .spec.source.repoURL }}"
            targetRevision = "{{ .spec.source.targetRevision }}"
            helm = {
              releaseName = "{{ .spec.source.helm.releaseName }}"
              values      = "{{ .spec.source.helm.valuesObject | toYaml | nindent 12}}"
            }
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "argocd_http_route" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "argocd-route"
      namespace = var.ARGOCD_NAMESPACE
    }
    spec = {
      parentRefs = [
        {
          name      = var.GATEWAY_NAME
          namespace = var.GATEWAY_NAMESPACE
        }
      ]
      hostnames = [
        local.argocd_domain
      ]
      rules = [
        {
          backendRefs = [
            {
              name = "${var.ARGOCD_NAMESPACE}-server"
              port = 80
            }
          ]
        }
      ]
    }
  }
}