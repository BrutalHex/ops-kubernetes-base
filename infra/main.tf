locals {
  keycloak_namespace = "keycloak-space"
  istio_namespace    = "istio-system"
  argocd_namespace   = "argocd"
  gateway_name       = "waypoint"
}

# "kubernetes-base" module setups the k8s environment
module "kubernetes-base" {
  source                                      = "./modules/kubernetes"
  AWS_IAM_ROLE_CSI_DRIVER_ARN                 = local.aws_iam_role_csi_driver_arn
  CSI_DRIVER_SERVICE_ACCOUNT_NAME             = local.csi_driver_service_account_name
  ROUTE53_SERVICE_ACCOUNT_NAME_EXTERNAL_DNS   = local.route53_service_account_name_external_dns
  SERVICE_ACCOUNT_NAME_CERT_MANAGER           = local.service_account_name_cert_manager
  SERVICE_ACCOUNT_NAME_CERT_MANAGER_NAMESPACE = local.service_account_name_cert_manager_namespace
  ROUTE53_ID                                  = local.route53_id
  AWS_IAM_ROLE_ROUTE53_ARN                    = local.aws_iam_role_route53_arn
  DOMAIN                                      = local.domain
  AWS_REGION                                  = var.AWS_REGION
  APP_NAME                                    = var.APP_NAME
  CLUSTER_AUTOSCALER_ROLE                     = local.cluster_autoscaler_role
  AWS_IAM_ROLE_LOAD_BALANCER_ARN              = local.aws_iam_role_load_balancer_arn
  LOAD_BALANCER_SERVICE_ACCOUNT               = local.load_balancer_service_account
  CERT_EMAIL                                  = var.CERT_EMAIL
  ARGOCD_APPS_REPOSITORY                      = var.ARGOCD_APPS_REPOSITORY
  ARGOCD_ADMIN_PASSWORD                       = var.ARGOCD_ADMIN_PASSWORD
  VPC_ID                                      = local.vpc_id
  KEYCLOAK_NAMESPACE                          = local.keycloak_namespace
  GATEWAY_NAMESPACE                           = local.istio_namespace
  GATEWAY_NAME                                = local.gateway_name
  ARGOCD_NAMESPACE                            = local.argocd_namespace
}

module "kubernetes-istio" {
  depends_on     = [module.kubernetes-base]
  source         = "./modules/istio"
  DOMAIN         = local.domain
  APP_NAME       = var.APP_NAME
  NAMESPACE      = local.istio_namespace
  CERT_NAMESPACE = local.service_account_name_cert_manager_namespace
  GATEWAY_NAME   = local.gateway_name
}

module "kubernetes-authorization" {
  depends_on      = [module.kubernetes-base, module.kubernetes-istio]
  source          = "./modules/authorization"
  DOMAIN          = local.domain
  APP_NAME        = var.APP_NAME
  NAMESPACE       = local.keycloak_namespace
  ISTIO_NAMESPACE = local.istio_namespace
  GATEWAY_NAME    = local.gateway_name
  WHITE_LISTED_NAMESPACES = [
    local.istio_namespace,
    local.keycloak_namespace,
    local.argocd_namespace,
    local.service_account_name_cert_manager_namespace,
    "default"
  ]
}
