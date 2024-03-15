module "aws_cluster_autoscaler" {
  count = var.cluster_autoscaler != null ? 1 : 0

  source              = "./modules/aws-cluster-autoscaler"
  eks_cluster_name    = var.cluster_name
  eks_cluster_version = var.cluster_version
  oidc_issuer_url     = var.cluster_oidc_issuer_url
  k8s_namespace       = var.cluster_autoscaler.namespace
  helm_chart_version  = var.cluster_autoscaler.version
  tolerations         = local.tolerations
  node_affinity       = local.node_affinity
  tags                = var.tags
}
