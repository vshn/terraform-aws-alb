resource "aws_iam_policy" "alb_ingress_policy" {
  name_prefix = "alb-ingress-policy"
  policy      = data.aws_iam_policy_document.alb_controller_policy_doc.json
}

module "alb_ingress_role" {
  source          = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version         = "6.3.0"
  name            = "alb-ingress-controller-role"
  use_name_prefix = true
  description     = "ALB Ingress Controller Role"
  oidc_providers = {
    provider = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.alb_controller_namespace}:${var.alb_controller_sa_name}"]
    }
  }
  policies = {
    alb_controller = aws_iam_policy.alb_ingress_policy.arn
  }
}

resource "helm_release" "alb_ingress_controller" {
  atomic          = true
  chart           = "aws-load-balancer-controller"
  cleanup_on_fail = true
  name            = "aws-load-balancer-controller"
  namespace       = var.alb_controller_namespace
  repository      = "https://aws.github.io/eks-charts"
  timeout         = 300
  version         = var.alb_controller_helm_chart_version

  set = [
    {
      name  = "image.repository"
      value = var.alb_controller_helm_image_repository
      type  = "string"
    },
    {
      name  = "clusterName"
      value = var.cluster_name
      type  = "string"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
      type  = "string"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.alb_ingress_role.arn
      type  = "string"
    },
    {
      name  = "serviceAccount.name"
      value = var.alb_controller_sa_name
      type  = "string"
    },
    {
      name  = "defaultSSLPolicy"
      value = var.alb_controller_default_ssl_policy
      type  = "string"
    }
  ]
}
