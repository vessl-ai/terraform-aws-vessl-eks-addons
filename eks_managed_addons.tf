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
