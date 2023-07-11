module "aws_load_balancer_controller" {
  count = var.load_balancer_controller != null ? 1 : 0

  source             = "./modules/aws-load-balancer-controller"
  eks_cluster_name   = var.cluster_name
  oidc_issuer_url    = var.cluster_oidc_issuer_url
  oidc_provider_arn  = var.cluster_oidc_provider_arn
  k8s_namespace      = var.load_balancer_controller.namespace
  helm_chart_version = var.load_balancer_controller.version
  tolerations        = var.tolerations
  tags               = var.tags
}

module "aws_cluster_autoscaler" {
  count = var.cluster_autoscaler != null ? 1 : 0

  source              = "./modules/aws-cluster-autoscaler"
  eks_cluster_name    = var.cluster_name
  eks_cluster_version = var.cluster_version
  oidc_issuer_url     = var.cluster_oidc_issuer_url
  k8s_namespace       = var.cluster_autoscaler.namespace
  helm_chart_version  = var.cluster_autoscaler.version
  tolerations         = var.tolerations
  tags                = var.tags
}
