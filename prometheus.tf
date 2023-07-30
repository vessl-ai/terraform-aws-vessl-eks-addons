module "prometheus" {
  count  = var.prometheus != null ? 1 : 0
  source = "./modules/prometheus"

  namespace = "prometheus"
  server = {
    enabled = var.prometheus.server.enabled
    version = var.prometheus.server.version
  }
  operator_crds = {
    enabled = var.prometheus.operator_crds.enabled
    version = var.prometheus.operator_crds.version
  }
  operator_admission_webhook = {
    enabled = var.prometheus.operator_admission_webhooks.enabled
    version = var.prometheus.operator_admission_webhooks.version
  }
  adapter = {
    enabled = var.prometheus.adapter.enabled
    version = var.prometheus.adapter.version
  }

  tolerations    = var.tolerations
  node_selectors = var.node_selectors
  tags           = var.tags
}
