resource "helm_release" "external-dns" {
  depends_on = [kubernetes_namespace.namespace]
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "7.5.2"

  set {
    name  = "registry"
    value = "txt"
  }
  set {
    name  = "txtOwnerId"
    value = var.APP_NAME
  }
  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.zoneType"
    value = "public"
  }

  set {
    name  = "sources"
    value = "{ingress}"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = var.ROUTE53_SERVICE_ACCOUNT_NAME_EXTERNAL_DNS
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

}