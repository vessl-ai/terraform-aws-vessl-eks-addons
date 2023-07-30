module "prometheus_remote_write" {
  count  = var.prometheus_remote_write != null ? 1 : 0
  source = "./modules/prometheus-remote-write"

  namespace = var.prometheus_remote_write.namespace
  server = {
    enabled = var.prometheus_remote_write.server.enabled
    version = var.prometheus_remote_write.server.version
    url     = var.prometheus_remote_write.server.url
  }
  operator_crds = {
    enabled = var.prometheus_remote_write.operator_crds.enabled
    version = var.prometheus_remote_write.operator_crds.version
  }
  operator_admission_webhook = {
    enabled = var.prometheus_remote_write.operator_admission_webhook.enabled
    version = var.prometheus_remote_write.operator_admission_webhook.version
  }
  adapter = {
    enabled = var.prometheus_remote_write.adapter.enabled
    version = var.prometheus_remote_write.adapter.version
  }

  tolerations    = var.tolerations
  node_selectors = var.node_selectors
  tags           = var.tags
}
