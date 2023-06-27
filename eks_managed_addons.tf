locals {
  eks_addon_default_tolerations = [
    {
      key      = "node-role.kubernetes.io/master"
      operator = "Exists"
      effect   = "NoSchedule"
    },
    {
      key      = "CriticalAddonsOnly"
      operator = "Exists"
      effect   = "NoSchedule"
    }
  ]
  eks_addon_tolerations = concat(var.tolerations, local.eks_addon_default_tolerations)
}

resource "aws_eks_addon" "coredns" {
  count = var.coredns != null ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  addon_version               = var.coredns.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values = jsonencode({
    tolerations = [
      for i, v in local.eks_addon_tolerations : {
        key      = v.key
        operator = v.operator
        effect   = v.effect
      }
    ]
  })
}

resource "aws_eks_addon" "kube_proxy" {
  count = var.kube_proxy != null ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = var.kube_proxy.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values = jsonencode({
    tolerations = [
      for i, v in local.eks_addon_tolerations : {
        key      = v.key
        operator = v.operator
        effect   = v.effect
      }
    ]
  })
}

resource "aws_eks_addon" "vpc_cni" {
  count = var.vpc_cni != null ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values = jsonencode({
    tolerations = [
      for i, v in local.eks_addon_tolerations : {
        key      = v.key
        operator = v.operator
        effect   = v.effect
      }
    ]
  })
}

resource "aws_eks_addon" "ebs_csi_driver" {
  count = var.ebs_csi_driver != null ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.ebs_csi_driver.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values = jsonencode({
    tolerations = [
      for i, v in local.eks_addon_tolerations : {
        key      = v.key
        operator = v.operator
        effect   = v.effect
      }
    ]
  })
}
