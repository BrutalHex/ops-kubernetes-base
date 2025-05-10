
variable "VPC_ID" {
  description = "The ID of the VPC where the EKS cluster is deployed."
}

variable "CSI_DRIVER_SERVICE_ACCOUNT_NAME" {
  description = "The name of the Kubernetes service account used by the CSI (Container Storage Interface) driver."
}

variable "AWS_IAM_ROLE_CSI_DRIVER_ARN" {
  description = "The ARN of the AWS IAM role associated with the CSI driver for permissions to manage EBS volumes."
}

variable "AWS_REGION" {
  description = "The AWS region where the resources are being deployed (e.g., us-east-1, eu-west-1)."
}

variable "APP_NAME" {
  description = "The name of the application being deployed, used for labeling and resource identification."
}

variable "ROUTE53_ID" {
  description = "The ID of the AWS Route 53 hosted zone where DNS records will be managed."
}

variable "ROUTE53_SERVICE_ACCOUNT_NAME_EXTERNAL_DNS" {
  description = "The name of the Kubernetes service account used by ExternalDNS to manage Route 53 DNS records."
}

variable "SERVICE_ACCOUNT_NAME_CERT_MANAGER" {
  description = "The name of the Kubernetes service account used by the Cert-Manager component."
}

variable "SERVICE_ACCOUNT_NAME_CERT_MANAGER_NAMESPACE" {
  description = "The Kubernetes namespace where the Cert-Manager service account is located."
}

variable "AWS_IAM_ROLE_ROUTE53_ARN" {
  description = "The ARN of the AWS IAM role with permissions to manage Route 53 records."
}

variable "DOMAIN" {
  description = "The domain name for which DNS and TLS certificates will be managed."
}

variable "CERT_EMAIL" {
  description = "The email address used for TLS certificate registration and notifications."
}

variable "CLUSTER_AUTOSCALER_ROLE" {
  description = "The name or ARN of the IAM role used by the Kubernetes Cluster Autoscaler."
}

variable "AWS_IAM_ROLE_LOAD_BALANCER_ARN" {
  description = "The ARN of the AWS IAM role with permissions to manage Load Balancer resources."
}

variable "LOAD_BALANCER_SERVICE_ACCOUNT" {
  description = "The name of the Kubernetes service account used for managing Load Balancer"
}

variable "ARGOCD_APPS_REPOSITORY" {
  description = "The URL of the ArgoCD apps repository"
  type        = string
}

variable "ARGOCD_ADMIN_PASSWORD" {
  description = "The initial password for the ArgoCD admin user"
  type        = string
  sensitive   = true
}
variable "KEYCLOAK_NAMESPACE" {
  description = "The keyclaok namespace"
  type        = string
}
variable "GATEWAY_NAME" {
  description = "The name of the gateway"
  type        = string
}
variable "GATEWAY_NAMESPACE" {
  description = "The namespace of the gateway"
  type        = string
}

variable "ARGOCD_NAMESPACE" {
  description = "The argocd namespace"
  type        = string
}