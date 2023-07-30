locals {
  node_affinity = {
    preferredDuringSchedulingIgnoredDuringExecution = [
      for nodeSelector in var.node_selectors : {
        weight = 1
        preference = {
          matchExpressions = [{
            key      = nodeSelector.key
            operator = "In"
            values   = [nodeSelector.value]
          }]
        }
      }
    ]
  }

  // https://github.com/prometheus-community/helm-charts/blob/7e407a73f02272f3d608f5f8dbe72395f7ace57b/charts/prometheus-operator-admission-webhook/values.yaml
  helm_values = {
    tolerations = var.tolerations
    affinity = {
      nodeAffinity = local.node_affinity
    }
    jobs = {
      tolerations = var.tolerations
      affinity = {
        nodeAffinity = local.node_affinity
      }
    }
  }
}

resource "helm_release" "prometheus_operator_admission_webhook" {
  count = var.operator_admission_webhook != null && var.operator_admission_webhook.enabled ? 1 : 0

  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-operator-admission-webhook"
  name             = "prometheus-operator-admission-webhook"
  version          = var.operator_admission_webhook.version
  namespace        = var.namespace
  values           = [yamlencode(local.helm_values)]
}
