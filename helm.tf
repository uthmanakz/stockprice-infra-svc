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


resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6"
  namespace        = "argocd"
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

  depends_on = [helm_release.aws_load_balancer_controller]

}

# resource "null_resource" "patch_argocd_service" {
#   depends_on = [helm_release.argocd]

#   provisioner "local-exec" {
#     command = <<EOT
#       kubectl patch svc argocd-server -n argocd \
#         -p '{"spec": {"type": "LoadBalancer"}}'
#     EOT
#   }
# }



