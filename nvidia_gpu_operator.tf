resource "kubernetes_namespace_v1" "nvidia_gpu_operator" {
  metadata {
    name = var.nvidia_gpu_operator.namespace
  }
  timeouts {
    delete = "15m"
  }
}

resource "helm_release" "nvidia_gpu_operator" {
  count = var.nvidia_gpu_operator != null ? 1 : 0

  repository = "https://nvidia.github.io/gpu-operator"
  chart      = "gpu-operator"
  namespace  = var.nvidia_gpu_operator.namespace
  name       = "gpu-operator"
  version    = var.nvidia_gpu_operator.version

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "nvidia-gpu-operator"
  }

  set {
    name  = "toolkit.version"
    value = "v1.12.0-centos7"
  }

  set {
    name  = "validator.plugin.env[0].name"
    value = "WITH_WORKLOAD"
    type  = "string"
  }

  set {
    name  = "validator.plugin.env[0].value"
    value = "false"
    type  = "string"
  }

  set {
    name  = "dcgmExporter.enabled"
    value = "false"
  }

  depends_on = [
    kubernetes_namespace_v1.nvidia_gpu_operator
  ]
}
