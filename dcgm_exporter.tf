locals {
  dcgm_exporter_node_affinity = {
    requiredDuringSchedulingIgnoredDuringExecution = [{
      key      = "nvidia.com/gpu.present"
      operator = "Exists"
    }]
  }
  // https://github.com/NVIDIA/dcgm-exporter/blob/e55ec750def325f9f1fdbd0a6f98c932672002e4/deployment/values.yaml
  dcgm_exporter_helm_values = {
    affinity = {
      nodeAffinity = local.dcgm_exporter_node_affinity
    }
  }
}

resource "helm_release" "dcgm_exporter" {
  count = var.dcgm_exporter != null ? 1 : 0

  repository = "https://nvidia.github.io/dcgm-exporter/helm-charts"
  chart      = "dcgm-exporter"
  name       = "dcgm-exporter"
  version    = var.dcgm_exporter.version
  namespace  = var.dcgm_exporter.namespace
  values     = [yamlencode(local.dcgm_exporter_helm_values)]

  dynamic "set" {
    for_each = var.dcgm_exporter.helm_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
