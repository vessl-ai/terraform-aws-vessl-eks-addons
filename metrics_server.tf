locals {
  metrics_server_helm_values = {
    tolerations = local.tolerations
    affinity = {
      nodeAffinity = local.node_affinity
    }
  }
}

resource "helm_release" "metrics_server" {
  count = var.metrics_server != null ? 1 : 0

  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  name       = "metrics-server"
  version    = var.metrics_server.version
  namespace  = var.metrics_server.namespace
  values     = [yamlencode(merge(local.metrics_server_helm_values, var.metrics_server.helm_values))]
}
