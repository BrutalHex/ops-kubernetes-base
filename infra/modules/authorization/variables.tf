variable "DOMAIN" {
  description = "The domain name for which DNS and TLS certificates will be managed."
}

variable "APP_NAME" {
  description = "The name of the application group"
  type        = string
  default     = "myapp"
}
variable "NAMESPACE" {
  description = "The authorization service namespace"
  type        = string
}
variable "ISTIO_NAMESPACE" {
  description = "The istio namespace"
  type        = string
}

variable "GATEWAY_NAME" {
  description = "The name of the gateway"
  type        = string
}


variable "WHITE_LISTED_NAMESPACES" {
  type        = list(string)
  description = "allows communication between mentioned namespaces"
}