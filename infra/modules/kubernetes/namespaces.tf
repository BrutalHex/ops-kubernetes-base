

locals {
  namespaces = [
    var.NAMESPACES_NGINX,
    var.SERVICE_ACCOUNT_NAME_CERT_MANAGER_NAMESPACE,
    local.argocd_namespace,
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
      "${var.APP_NAME}" = "true"
    }
  }
}

resource "time_sleep" "destroy_wait_10_seconds" {
  depends_on       = [kubernetes_namespace.namespace]
  destroy_duration = "10s"
}
