locals {
  argocd_namespace = "argocd"
}

resource "helm_release" "argocd" {
  depends_on       = [helm_release.aws_load_balancer_controller, kubernetes_namespace.namespace, helm_release.ingress-nginx]
  name             = local.argocd_namespace
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.8.2"
  namespace        = local.argocd_namespace
  create_namespace = false
  values = [yamlencode({
    crds = {
      install = false
    }
    global = {
      domain = "argocd.${var.DOMAIN}"
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
        extraTls         = {}
        tls              = false
        enabled          = true
        ingressClassName = "nginx"
        annotations = {
          "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
          "nginx.ingress.kubernetes.io/ssl-passthrough"    = "false"
        }
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
      namespace = "argocd"
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
            namespace = "argocd"
          }
          source = {
            chart          = "{{ .spec.source.chart }}"
            repoURL        = "{{ .spec.source.repoURL }}"
            targetRevision = "{{ .spec.source.targetRevision }}"
            helm = {
              values = "{{ .spec.source.helm.valuesObject | toYaml | nindent 12}}"
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
