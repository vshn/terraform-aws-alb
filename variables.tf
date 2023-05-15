variable "cluster_name" {
  type = string
}

variable "alb_controller_namespace" {
  description = "The namespace the ALB ingress controller is deployed to."
  type        = string
  default     = "kube-system"
}

variable "alb_controller_sa_name" {
  description = "The service account name used for AWS ALB Ingress controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "alb_controller_helm_chart_version" {
  description = "The version of the helm chart."
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the openid connect provider."
  type        = string
}

variable "alb_controller_helm_image_repository" {
  description = "The image repository of the region. I.e. 602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller. See also https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html"
  type        = string
}
