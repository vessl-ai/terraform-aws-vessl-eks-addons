locals {
  prometheus_server_node_affinity = {
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

  // https://github.com/prometheus-community/helm-charts/blob/7e407a73f02272f3d608f5f8dbe72395f7ace57b/charts/prometheus/values.yaml
  prometheus_server_helm_values = {
    server = {
      tolerations = var.tolerations
      affinity = {
        nodeAffinity = local.prometheus_server_node_affinity
      }
      remoteWrite = [
        {
          name = "vessl-remote-write"
          url  = var.server.url
          authorization = {
            type = "Token"
            credentials = {
              name = "vessl-agent"
              key  = "access-token"
            }
          }
          writeRelabelConfigs = [
            {
              action = "labeldrop"
              regex  = "feature_node_kubernetes_io_(.+)"
            },
            {
              action = "labeldrop"
              regex  = "label_feature_node_kubernetes_io_(.+)"
            },
            {
              action = "labeldrop"
              regex  = "minikube_(.+)"
            },
          ]
        }
      ]
    }
    alertmanager = {
      enabled = false
    }
    kube-state-metrics = {
      enabled = false
    }
    prometheus-node-exporter = {
      enabled = false
    }
    prometheus-push-gateway = {
      enabled = false
    }
  }
}

resource "helm_release" "prometheus_server" {
  count = var.server != null && var.server.enabled ? 1 : 0

  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  name             = "prometheus"
  version          = var.server.version
  namespace        = var.namespace
  values           = [yamlencode(local.prometheus_server_helm_values)]
}
