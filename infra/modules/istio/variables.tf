variable "CERT_NAMESPACE" {
  description = "The Kubernetes namespace where the Certificate is located."
}

variable "DOMAIN" {
  description = "The domain name for which DNS and TLS certificates will be managed."
}

variable "APP_NAME" {
  description = "The name of the application group"
  type        = string
  default     = "myapp"
}
variable "NAMESPACE" {
  description = "The istio namespace"
  type        = string
}
variable "GATEWAY_NAME" {
  description = "The name of the gateway"
  type        = string
}