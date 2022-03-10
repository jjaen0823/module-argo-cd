# kubernetes와 Helm provider 구성 (p203)
provider "kubernetes" {
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
  host                   = var.kubernetes_cluster_endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws-iam-authenticator"
    args        = ["", "-i", "${var.kubernetes_cluster_name}"]
  }
}


provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_cert_data)
    host                   = var.kubernetes_cluster_endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      command     = "aws-iam-authenticator"
      args        = ["", "-i", "${var.kubernetes_cluster_name}"]
    }
  }
}

# Argo CD community에서 제공하는 Heml Chart를 사용해 Argo CD 설치 (p204)
resource "kubernetes_namespace" "argo-ns" {
  metadata {
    name = "argocd"
  }
}

# Helm provider를 사용해 Argo CD 설치
resource "helm_release" "argocd" {
  name       = "msur"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm" # community repo
  namespace  = "argocd"
  version    = "2.2.5"
}

# GitOps 구성
module "argo-cd-server" {
    source = "git::https://github.com/jjaen0823/module-argo-cd.git"

    kubernetes_cluster_id = module.aws-eks.eks_cluster_id
    kubernetes_cluster_name = module.aws-eks.eks_cluster_name
    kubernetes_cluster_cert_data = module.aws-eks.eks_cluster_certificate_data
    kubernetes_cluster_endpoint = module.aws-eks.eks_cluster_endpoint
    eks_nodegroup_id = module.aws-eks.eks_cluster_nodegroup_id
}