locals {
  tags = merge(var.tags, {
    "vessl:component" = "addon/external-dns",
  })

  external_dns_node_affinity = {
    preferredDuringSchedulingIgnoredDuringExecution = [
      for nodeSelector in var.node_selectors : {
        weight = 1
        preference = {
          matchExpressions = [{
            key      = nodeSelector.key
            operator = "In"
            values   = [nodeSelector.value]
          }]
        }
      }
    ]
  }

  // https://github.com/kubernetes-sigs/external-dns/blob/bc61d4deb357c9283fda5b199c0ab52283a91b88/charts/external-dns/values.yaml
  external_dns_helm_values = {
    serviceAccount = {
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns.arn
      }
      create = true
      name   = var.k8s_service_account_name
    }
    affinity = {
      nodeAffinity = local.external_dns_node_affinity
    }
    tolerations = var.tolerations
  }
}

resource "helm_release" "external_dns" {
  repository = var.helm_repo_url
  chart      = var.helm_chart_name

  namespace = var.k8s_namespace
  name      = var.helm_release_name
  version   = var.helm_chart_version
  values    = [yamlencode(merge(local.external_dns_helm_values, var.helm_values))]
}
