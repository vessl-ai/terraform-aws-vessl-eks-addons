data "aws_region" "current" {}

locals {
  tags = merge(var.tags, {
    "vessl:component" = "addon/cluster-autoscaler"
  })

  // https://github.com/kubernetes/autoscaler/blob/63eab4efdfe98f07ed59fa29839119290f0f5157/charts/cluster-autoscaler/values.yaml
  helm_values = {
    awsRegion = data.aws_region.current.name
    autoDiscovery = {
      clusterName = var.eks_cluster_name
    }
    image = {
      tag = "v${var.eks_cluster_version}.0"
    }
    resources = {
      limits = {
        cpu    = "200m"
        memory = "512Mi"
      }
      requests = {
        cpu    = "200m"
        memory = "512Mi"
      }
    }
    rbac = {
      serviceAccount = {
        create = true
        name   = var.k8s_service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
        }
      }
    }
    extraArgs = {
      "balance-similar-node-groups" = "true"
      "scale-down-delay-after-add"  = "10s"
      "scale-down-unneeded-time"    = "3m"
      "expander"                    = "priority"
    }
    expanderPriorities = <<EOT
      2:
        - ".*-m[5|6|7][i]*-.*large-.*"
      1:
        - ".*"
    EOT
    affinity = {
      nodeAffinity = var.node_affinity
    }
    tolerations = var.tolerations
  }
}

resource "helm_release" "cluster_autoscaler" {
  repository = var.helm_repo_url
  chart      = var.helm_chart_name

  namespace = var.k8s_namespace
  name      = var.helm_release_name
  version   = var.helm_chart_version

  values = [yamlencode(merge(local.helm_values, var.helm_values))]
}
