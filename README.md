# Introduction

The `ops-kubernetes-base` project is responsible for configuring resources inside `Kubernetes`.  
It sets up essential workloads in EKS, including ArgoCD, Cert-Manager, and other foundational components.  

For more details, refer to the [ops-infra](https://github.com/BrutalHex/ops-infra) repository.  

## Setup
To initiate the configuration process, push your changes and trigger the [setup action](https://github.com/BrutalHex/ops-kubernetes-base/actions/workflows/setup.yaml).  

## Destroy
To destroy the resources, trigger the [destroy action](https://github.com/BrutalHex/ops-kubernetes-base/actions/workflows/destroy.yaml).

## 📁 **Folder Tree with Descriptions**
```
**ops-kubernetes-base**
├── **.github**:    Contains reusable GitHub Action definitions used in CI/CD workflows.
│   └── **workflows**:  GitHub Actions workflows for automating infrastructure setup and teardown.
├── **infra**:  Main Terraform infrastructure code
│   └── **modules**:    Reusable Terraform modules
│       ├── **authorization**:  Defines Terraform modules for Keycloak and Istio authorization policies (RBAC, JWT, OIDC integration).
│       ├── **istio**:  Contains Istio-related Terraform resources such as gateways, traffic rules, and observability addons.
│       └── **kubernetes**: Deploys base Kubernetes tools like ArgoCD, cert-manager and namespaces using Terraform.
```
