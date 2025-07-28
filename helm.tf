resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.0"

  set {
    name  = "clusterName"
    value = stockprice
  }

  set {
    name  = "region"
    value = eu-west-2
  }

  set {
    name  = "vpcId"
    value = data.terraform_remote_state.eks.outputs.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [kubernetes_service_account.alb_sa]
}
