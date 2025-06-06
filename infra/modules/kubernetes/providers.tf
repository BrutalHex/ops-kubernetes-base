terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.47.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.35.1"
    }
  }
}