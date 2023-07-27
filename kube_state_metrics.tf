resource "helm_release" "kube_state_metrics" {
  count = var.kube_state_metrics != null ? 1 : 0

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  name       = "kube-state-metrics"
  version    = var.kube_state_metrics.version
  namespace  = var.kube_state_metrics.namespace

  dynamic "set" {
    for_each = var.kube_state_metrics.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
