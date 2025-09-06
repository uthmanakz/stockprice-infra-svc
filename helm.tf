terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = data.terraform_remote_state.eks.outputs.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.eks_cluster_ca)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.0"

  set = [
    {
      name  = "clusterName"
      value = "stockprice"
    },
    {
      name  = "region"
      value = "eu-west-2"
    },
    {
      name  = "vpcId"
      value = data.terraform_remote_state.eks.outputs.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]

  depends_on = [kubernetes_service_account.alb_sa]
}

# Install Argo CD via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6" # Check for latest: https://artifacthub.io/packages/helm/argo/argo-cd
  create_namespace = true

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer" 
    },
    {
      name  = "controller.replicaCount"
      value = "2"
    }
  ]
}
