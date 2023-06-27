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
}

resource "aws_eks_addon" "vpc_cni" {
  count = var.vpc_cni != null ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  count = var.ebs_csi_driver != null ? 1 : 0

  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_driver.version
  service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values = jsonencode({
    controller = {
      tolerations = [
        for i, v in local.eks_addon_tolerations : {
          key      = v.key
          operator = v.operator
          effect   = v.effect
        }
      ]
    }
    node = {
      tolerations = [
        for i, v in local.eks_addon_tolerations : {
          key      = v.key
          operator = v.operator
          effect   = v.effect
        }
      ]
    }
  })
}

resource "kubernetes_storage_class_v1" "ebs-csi" {
  count = var.ebs_csi_driver != null ? 1 : 0

  metadata {
    name = var.ebs_csi_driver.storage_class_name
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}
