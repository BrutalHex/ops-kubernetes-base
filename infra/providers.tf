terraform {
  backend "s3" {
    bucket = "terraform-state-ops-infra"
    key    = "kubereks/01-state-kubernetes-base.tfstate"
    region = "eu-west-1"
  }

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
  required_version = ">=1.8.2"
}
provider "local" {
  # The local provider is needed for null_resource and local-exec
}

provider "aws" {
  region = var.AWS_REGION
}

data "aws_secretsmanager_secret_version" "eks-cluster" {
  secret_id = var.EKS_CLUSTER_SECRET_ID
}

locals {
  secret                                      = jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.eks-cluster.secret_string))
  endpoint                                    = local.secret["endpoint"]
  cluster_autoscaler_role                     = local.secret["cluster_autoscaler_role"]
  csi_driver_service_account_name             = local.secret["csi_driver_service_account_name"]
  aws_iam_role_csi_driver_arn                 = local.secret["aws_iam_role_csi_driver_arn"]
  route53_service_account_name_external_dns   = local.secret["route53_service_account_name_external_dns"]
  service_account_name_cert_manager           = local.secret["service_account_name_cert_manager"]
  service_account_name_cert_manager_namespace = local.secret["service_account_name_cert_manager_namespace"]
  aws_iam_role_route53_arn                    = local.secret["aws_iam_role_route53_arn"]
  route53_id                                  = local.secret["route53_id"]
  domain                                      = local.secret["domain"]
  aws_iam_role_load_balancer_arn              = local.secret["aws_iam_role_load_balancer_arn"]
  load_balancer_service_account               = local.secret["load_balancer_service_account"]
  vpc_id                                      = local.secret["vpc_id"]
}



provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "time" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}