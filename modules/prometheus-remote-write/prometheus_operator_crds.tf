resource "helm_release" "prometheus_operator_crds" {
  count = var.operator_crds != null && var.operator_crds.enabled ? 1 : 0

  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-operator-crds"
  name             = "prometheus-operator-crds"
  version          = var.operator_crds.version
  namespace        = var.namespace
}
