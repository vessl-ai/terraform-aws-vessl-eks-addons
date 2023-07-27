resource "helm_release" "dcgm_exporter" {
  count = var.dcgm_exporter != null ? 1 : 0

  repository = "https://nvidia.github.io/dcgm-exporter/helm-charts"
  chart      = "dcgm-exporter"
  name       = "dcgm-exporter"
  version    = var.dcgm_exporter.version
  namespace  = var.dcgm_exporter.namespace

  dynamic "set" {
    for_each = var.dcgm_exporter.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
