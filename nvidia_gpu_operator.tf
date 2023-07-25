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
  gpu_operator_tolerations = concat(var.tolerations, local.gpu_operator_default_tolerations)

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
      [for _, nodeSelector in var.node_selectors : {
        weight = 1
        preference = {
          matchExpressions = [
            for labelKey, labelValue in nodeSelector : {
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

  gpu_operator_helm_values = {
    serviceAccount = {
      create = true
      name   = "nvidia-gpu-operator"
    }
    toolkit = {
      version = "v1.12.0-centos7"
    }
    validator = {
      plugin = {
        env = [
          {
            name  = "WITH_WORKLOAD"
            value = "false"
            type  = "string"
          }
        ]
      }
    }
    dcgmExporter = {
      enabled = false
    }
    operator = {
      affinity = {
        nodeAffinity = {
          preferredDuringSchedulingIgnoredDuringExecution = local.gpu_operator_node_affinity.preferredDuringSchedulingIgnoredDuringExecution
        }
      }
      tolerations = local.gpu_operator_tolerations
    }
    node-feature-discovery = {
      master = {
        affinity = {
          nodeAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = local.gpu_operator_node_affinity.preferredDuringSchedulingIgnoredDuringExecution
          }
        }
        tolerations = local.gpu_operator_tolerations
      }
    }
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
  count      = var.nvidia_gpu_operator != null ? 1 : 0
  depends_on = [kubernetes_namespace_v1.nvidia_gpu_operator]

  repository = "https://nvidia.github.io/gpu-operator"
  chart      = "gpu-operator"
  namespace  = var.nvidia_gpu_operator.namespace
  name       = "gpu-operator"
  version    = var.nvidia_gpu_operator.version

  values = [yamlencode(local.gpu_operator_helm_values)]
}
