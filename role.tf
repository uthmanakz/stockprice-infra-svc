# Look up existing IAM policy (created in another repo or manually)
data "aws_iam_policy" "aws_load_balancer_controller" {
  name = "AWSLoadBalancerControllerIAMPolicy"
}

# Look up existing IAM role (IRSA role created already)
resource "aws_iam_role" "alb_ingress_role" {
  name = "eks-alb-ingress-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.terraform_remote_state.eks.outputs.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${data.terraform_remote_state.eks.outputs.oidc_provider_arn}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller",
            "${data.terraform_remote_state.eks.outputs.oidc_provider}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}


# Create the Kubernetes ServiceAccount with IRSA annotation
resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_role.arn
    }
  }
}



# resource "aws_iam_policy" "aws_load_balancer_controller" {
#   name   = "AWSLoadBalancerControllerIAMPolicy"
#   policy = file("${path.module}/iam_policy.json")
# }


# module "ingress_irsa" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "~> 5.0"

#   role_name = "eks-alb-ingress-controller"

#   role_policy_arns = {
#   AWSLoadBalancerController = aws_iam_policy.aws_load_balancer_controller.arn
# }


#   oidc_providers = {
#     main = {
#       provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
#       namespace_service_accounts = [
#         "kube-system:aws-load-balancer-controller"
#       ]
#     }
#   }
#   tags                           = {
#     "Name" = "eks-alb-ingress-controller"
#   }

# }


