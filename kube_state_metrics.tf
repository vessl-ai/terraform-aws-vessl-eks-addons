locals {
  node_affinity = {
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

  // https://github.com/prometheus-community/helm-charts/blob/eae39d7447cfaeaf9aa00b8aec942ebce879861b/charts/kube-state-metrics/values.yaml
  helm_values = {
    tolerations = var.tolerations
    affinity = {
      nodeAffinity = local.node_affinity
    }
  }
}

resource "helm_release" "kube_state_metrics" {
  count = var.kube_state_metrics != null ? 1 : 0

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  name       = "kube-state-metrics"
  version    = var.kube_state_metrics.version
  namespace  = var.kube_state_metrics.namespace
  values     = [yamlencode(local.helm_values)]

  dynamic "set" {
    for_each = var.kube_state_metrics.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
