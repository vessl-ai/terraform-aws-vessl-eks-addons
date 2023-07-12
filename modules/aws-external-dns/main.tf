locals {
  tolerations = { for i, v in var.tolerations : i => v }
  tags = merge(var.tags, {
    "vessl:component" = "addon/external-dns",
  })
}

resource "helm_release" "external_dns" {
  repository = var.helm_repo_url
  chart      = var.helm_chart_name

  namespace = var.k8s_namespace
  name      = var.helm_release_name
  version   = var.helm_chart_version

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.k8s_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns.arn
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

  dynamic "set" {
    for_each = var.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
