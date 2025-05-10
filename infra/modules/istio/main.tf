
resource "kubernetes_namespace" "istio-namespace" {
  lifecycle {
    ignore_changes = [metadata]
  }
  metadata {
    name = var.NAMESPACE
    labels = {
      "${var.APP_NAME}" = "true"
    }
  }
}

resource "time_sleep" "destroy_wait_10_seconds" {
  depends_on       = [kubernetes_namespace.istio-namespace]
  destroy_duration = "10s"
}

resource "helm_release" "istio-base" {
  depends_on = [kubernetes_namespace.istio-namespace]
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio-namespace.metadata[0].name
  values = [yamlencode({
  })]
}
resource "helm_release" "istio-d" {
  depends_on = [kubernetes_namespace.istio-namespace, helm_release.istio-base]
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio-namespace.metadata[0].name
  values = [yamlencode({
    profile      = "ambient"
    replicaCount = 1
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

  })]
}

resource "helm_release" "istio-cni" {
  depends_on = [kubernetes_namespace.istio-namespace, helm_release.istio-base, helm_release.istio-d]
  name       = "istio-cni"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "cni"
  namespace  = kubernetes_namespace.istio-namespace.metadata[0].name
  values = [yamlencode({
    profile = "ambient"
    cni = {
      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
        limits = {
          cpu    = "250m"
          memory = "256Mi"
        }
    } }
  })]
}
resource "helm_release" "istio-ztunnel" {
  depends_on = [kubernetes_namespace.istio-namespace, helm_release.istio-cni]
  name       = "istio-ztunnel"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "ztunnel"
  namespace  = kubernetes_namespace.istio-namespace.metadata[0].name
  values = [yamlencode({
    replicaCount = 1
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
  })]
}