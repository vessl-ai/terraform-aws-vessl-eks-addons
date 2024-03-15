locals {
  // https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
  ingress_nginx_helm_values = {
    controller = {
      service = {
        type        = var.ingress_nginx.service_type
        annotations = var.ingress_nginx.service_annotations,
        targetPorts = try(var.ingress_nginx.ssl_termination, false) ? {
          http  = "http"
          https = "http"
          } : {
          http  = "http"
          https = "https"
        }
      }
      admissionWebhooks = {
        patch = {
          tolerations = local.tolerations
          nodeSelector = merge(
            { for expression in var.node_affinity : expression.key => expression.values[0] },
            { "kubernetes.io/os" : "linux" },
          )
        }
      }
      resources = {
        requests = {
          cpu    = "300m"
          memory = "500Mi"
        }
      }
      minAvailable = 2
      autoscaling = {
        enabled                           = true
        minReplicas                       = 2
        maxReplicas                       = 11
        targetCPUUtilizationPercentage    = 50
        targetMemoryUtilizationPercentage = 80
      }
      affinity = {
        nodeAffinity = local.node_affinity
      }
      tolerations = local.tolerations
    }
  }
}

resource "helm_release" "ingress_nginx" {
  count = var.ingress_nginx != null ? 1 : 0

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  name             = "ingress-nginx"
  version          = var.ingress_nginx.version
  namespace        = var.ingress_nginx.namespace
  create_namespace = var.ingress_nginx.create_namespace
  values           = var.ingress_nginx.extra_chart_values
}
