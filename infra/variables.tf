variable "AWS_REGION" {
  description = "the aws region that the infrastructure will be deployed"
  type        = string
}

variable "APP_ENVIRONMENT" {
  description = "The name of the environment, e.g., dev, test, etc."
  type        = string
}

variable "APP_NAME" {
  description = "The name of the application group"
  type        = string
  default     = "myapp"
}

variable "EKS_CLUSTER_SECRET_ID" {
  description = "The aws secret ID that holds information about of EKS cluster"
  type        = string
}

variable "CERT_EMAIL" {
  description = "The email to be used for Let's Encrypt registration"
  type        = string
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
