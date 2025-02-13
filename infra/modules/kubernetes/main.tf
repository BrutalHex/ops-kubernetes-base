resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = kubernetes_service_account.csi-driver-kube-system.metadata.0.namespace
  depends_on = [kubernetes_service_account.csi-driver-kube-system]
  set {
    name  = "controller.enableVolumeScheduling"
    value = "true"
  }

  set {
    name  = "controller.enableVolumeResizing"
    value = "true"
  }

  set {
    name  = "controller.enableVolumeSnapshot"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.autoMountServiceAccountToken"
    value = "true"
  }
  set {
    name  = "controller.serviceAccount.name"
    value = kubernetes_service_account.csi-driver-kube-system.metadata.0.name
  }
  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }
  set {
    name  = "replicaCount"
    value = "1"
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [helm_release.aws_ebs_csi_driver, helm_release.external-dns, kubernetes_namespace.namespace]
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.11.0"
  set {
    name  = "clusterName"
    value = var.APP_NAME
  }
  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.load-balancer-kube-system.metadata.0.name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "replicaCount"
    value = "1"
  }
  set {
    name  = "ingressClass"
    value = "nlb"
  }
  set {
    name  = "vpcId"
    value = var.VPC_ID
  }
  set {
    name  = "region"
    value = var.AWS_REGION
  }
}
