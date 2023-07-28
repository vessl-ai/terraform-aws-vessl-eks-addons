module "prometheus" {
  count  = var.prometheus != null ? 1 : 0
  source = "./modules/prometheus"

  namespace = "prometheus"
  operator_crds = {
    enabled = true
    version = "5.0.0"
  }

  tolerations    = var.tolerations
  node_selectors = var.node_selectors
  tags           = var.tags
}
