resource "helm_release" "node_exporter" {
  count = var.node_exporter != null ? 1 : 0

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  name       = "node-exporter"
  version    = var.node_exporter.version
  namespace  = var.node_exporter.namespace

  dynamic "set" {
    for_each = var.node_exporter.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
