locals {
  tolerations = { for i, v in var.tolerations : i => v }
  tags = merge(var.tags, {
    "vessl:component" = "load-balancer-controller",
  })
}

# Source: https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-controller/main/docs/install/iam_policy.json
resource "aws_iam_policy" "load_balancer_controller" {
  name   = "lb-controller-${var.eks_cluster_name}"
  policy = file("${path.module}/files/iam-policy.json")

  tags = local.tags
}

data "aws_iam_policy_document" "load_balancer_controller_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer_url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:load-balancer-controller",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "load_balancer_controller" {
  name               = "lb-controller-${var.eks_cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.load_balancer_controller_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}

resource "helm_release" "load_balancer_controller" {
  name       = "load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.k8s_namespace
  version    = var.helm_chart_version

  dynamic "set" {
    for_each = local.tags
    content {
      name  = "defaultTags.${set.key}"
      value = replace(set.value, ",", "\\,")
    }
  }

  dynamic "set" {
    for_each = local.tolerations
    content {
      name  = "tolerations[${set.key}].key"
      value = set.value.key
    }
  }

  dynamic "set" {
    for_each = local.tolerations
    content {
      name  = "tolerations[${set.key}].operator"
      value = set.value.operator
    }
  }

  dynamic "set" {
    for_each = local.tolerations
    content {
      name  = "tolerations[${set.key}].effect"
      value = set.value.effect
    }
  }

  values = [yamlencode(
    {
      clusterName = var.eks_cluster_name
      rbac = {
        create = true,
      }
      serviceAccount = {
        create = true,
        name   = "load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.load_balancer_controller.arn
        }
      }
    }
  )]
}
