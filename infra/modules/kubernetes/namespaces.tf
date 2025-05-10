

locals {
  namespaces = [
    var.SERVICE_ACCOUNT_NAME_CERT_MANAGER_NAMESPACE,
    var.ARGOCD_NAMESPACE,
    var.KEYCLOAK_NAMESPACE
  ]
}



resource "kubernetes_namespace" "namespace" {
  for_each = toset(local.namespaces)
  lifecycle {
    ignore_changes = [metadata]
  }

  metadata {
    name = each.value
    labels = {
      "${var.APP_NAME}"         = "true"
      "istio.io/dataplane-mode" = "ambient"
      "istio.io/use-waypoint"   = "waypoint"
    }
  }
}

resource "time_sleep" "destroy_wait_10_seconds" {
  depends_on       = [kubernetes_namespace.namespace]
  destroy_duration = "10s"
}
