locals {
  domain_parts  = try(split(".", var.external_dns.cluster_domain), [])
  domain_length = length(local.domain_parts)
  domain_name   = try("${local.domain_parts[local.domain_length - 2]}.${local.domain_parts[local.domain_length - 1]}", "")
}


data "aws_route53_zone" "this" {
  name = local.domain_name
}

resource "kubernetes_service" "tcp" {
  count = var.external_dns != null && var.ingress_nginx != null ? 1 : 0

  metadata {
    name      = "tcp"
    namespace = var.external_dns.namespace
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

  source                  = "./modules/aws-external-dns"
  eks_cluster_name        = var.cluster_name
  route53_hosted_zone_ids = [data.aws_route53_zone.this.id]
  k8s_create_namespace    = false
  k8s_namespace           = var.external_dns.namespace
  helm_chart_version      = var.external_dns.version
  helm_values = merge(
    { for i, source in var.external_dns.sources : "sources[${i}]" => source },
    { "txtOwnerId" : "vessl" },
  )
  tolerations = var.tolerations
}
