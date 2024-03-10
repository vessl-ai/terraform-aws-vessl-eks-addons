locals {
  domain_parts  = try(split(".", var.external_dns.cluster_domain), [])
  domain_length = length(local.domain_parts)
  domain_name   = var.external_dns.cluster_hosted_zone_domain == "" ? try(join(".", slice(local.domain_parts, local.domain_length - 2, local.domain_length)), "") : var.external_dns.cluster_hosted_zone_domain
}


data "aws_route53_zone" "cluster_domain" {
  count = var.external_dns != null && var.ingress_nginx != null ? 1 : 0
  name  = local.domain_name
}

data "aws_route53_zone" "extra_domains" {
  for_each = toset(try(var.external_dns.extra_domains, []))
  name     = each.value
}

resource "kubernetes_service" "tcp" {
  depends_on = [helm_release.ingress_nginx]
  count      = var.external_dns != null && var.ingress_nginx != null ? 1 : 0

  metadata {
    name      = "tcp"
    namespace = var.ingress_nginx.namespace
    annotations = {
      "external-dns.alpha.kubernetes.io/hostname"       = "tcp.${var.external_dns.cluster_domain}"
      "external-dns.alpha.kubernetes.io/endpoints-type" = "NodeExternalIP"
    }
  }
  spec {
    cluster_ip = "None"
    selector = {
      "app.kubernetes.io/instance"  = "ingress-nginx"
      "app.kubernetes.io/component" = "controller"
    }
  }
}

module "aws_external_dns" {
  count = var.external_dns != null ? 1 : 0

  source           = "./modules/aws-external-dns"
  eks_cluster_name = var.cluster_name
  route53_hosted_zone_ids = concat(
    [data.aws_route53_zone.cluster_domain[0].zone_id],
    [for extra_zone in data.aws_route53_zone.extra_domains : extra_zone.zone_id],
  )
  k8s_create_namespace = false
  k8s_namespace        = var.external_dns.namespace
  helm_chart_version   = var.external_dns.version
  helm_values = merge(
    var.external_dns.helm_values,
    { for i, source in var.external_dns.sources : "sources[${i}]" => source },
    { "txtOwnerId" : "vessl" },
  )
  tolerations    = var.tolerations
  node_selectors = var.node_selectors
  tags           = var.tags
}
