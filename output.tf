output "alb_irsa_role_arn" {
  value = module.ingress_irsa.iam_role_arn
}