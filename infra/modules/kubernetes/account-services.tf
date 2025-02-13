
resource "kubernetes_service_account" "csi-driver-kube-system" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = var.CSI_DRIVER_SERVICE_ACCOUNT_NAME
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${var.AWS_IAM_ROLE_CSI_DRIVER_ARN}"
    }
  }
}

resource "kubernetes_service_account" "route53-kube-system" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = var.ROUTE53_SERVICE_ACCOUNT_NAME_EXTERNAL_DNS
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${var.AWS_IAM_ROLE_ROUTE53_ARN}"
    }
  }
}

resource "kubernetes_service_account" "load-balancer-kube-system" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = var.LOAD_BALANCER_SERVICE_ACCOUNT
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${var.AWS_IAM_ROLE_LOAD_BALANCER_ARN}"
    }
  }
}


resource "kubernetes_service_account" "route53-cert-manager" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = var.SERVICE_ACCOUNT_NAME_CERT_MANAGER
    namespace = var.SERVICE_ACCOUNT_NAME_CERT_MANAGER_NAMESPACE
    annotations = {
      "eks.amazonaws.com/role-arn" = "${var.AWS_IAM_ROLE_ROUTE53_ARN}"
    }
  }
}

