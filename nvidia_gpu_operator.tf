locals {
  gpu_operator_default_tolerations = [
    {
      key      = "node-role.kubernetes.io/master"
      operator = "Exists"
      effect   = "NoSchedule"
    },
    {
      key      = "node-role.kubernetes.io/control-plane"
      operator = "Exists"
      effect   = "NoSchedule"
    }
  ]
  gpu_operator_tolerations = { for i, v in concat(var.tolerations, local.gpu_operator_default_tolerations) : i => v }

  gpu_operator_default_node_affinity = {
    preferredDuringSchedulingIgnoredDuringExecution = [
      {
        weight = 1
        preference = {
          matchExpressions = {
            key      = "node-role.kubernetes.io/master"
            operator = "In"
            values   = [""]
          }
        }
      },
      {
        weight = 1
        preference = {
          matchExpressions = {
            key      = "node-role.kubernetes.io/control-plane"
            operator = "In"
            values   = [""]
          }
        }
      }
    ]
  }
  gpu_operator_node_affinity = {
    preferredDuringSchedulingIgnoredDuringExecution = concat(
      [for _, v in var.node_selectors : {
        weight = 1
        preference = {
          matchExpressions = [
            for labelKey, labelValue in v : {
              key      = labelKey
              operator = "In"
              values   = [labelValue]
            }
          ]
        }
      }],
      local.gpu_operator_default_node_affinity.preferredDuringSchedulingIgnoredDuringExecution,
    )
  }
}

resource "kubernetes_namespace_v1" "nvidia_gpu_operator" {
  count = var.nvidia_gpu_operator != null ? 1 : 0

  metadata {
    name = var.nvidia_gpu_operator.namespace
  }
  timeouts {
    delete = "15m"
  }
}

resource "helm_release" "nvidia_gpu_operator" {
  // https://github.com/NVIDIA/gpu-operator/blob/2f0a16684157a9171939702a8b5322363c6d93e9/deployments/gpu-operator/values.yaml
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

  set_list {
    name  = "operator.tolerations"
    value = local.gpu_operator_tolerations
  }

  set_list {
    name  = "operator.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution"
    value = local.gpu_operator_node_affinity.preferredDuringSchedulingIgnoredDuringExecution
  }

  set_list {
    name  = "node-feature-discovery.master.tolerations"
    value = local.gpu_operator_tolerations
  }

  set_list {
    name  = "node-feature-discovery.master.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution"
    value = local.gpu_operator_node_affinity.preferredDuringSchedulingIgnoredDuringExecution
  }

  depends_on = [
    kubernetes_namespace_v1.nvidia_gpu_operator
  ]
}
