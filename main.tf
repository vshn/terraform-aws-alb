resource "aws_iam_policy" "alb_ingress_policy" {
  name_prefix = "alb-ingress-policy"
  policy      = data.aws_iam_policy_document.alb_controller_policy_doc.json
}


module "alb_ingress_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.31.0"
  create_role                   = true
  role_description              = "ALB Ingress Controller Role"
  role_name_prefix              = "alb-ingress-controller-role"
  provider_url                  = var.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.alb_ingress_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.alb_controller_namespace}:${var.alb_controller_sa_name}"]
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

  set {
    name  = "image.repository"
    value = var.alb_controller_helm_image_repository
    type  = "string"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
    type  = "string"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
    type  = "string"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb_ingress_role.iam_role_arn
    type  = "string"
  }

  set {
    name  = "serviceAccount.name"
    value = var.alb_controller_sa_name
    type  = "string"
  }
}
