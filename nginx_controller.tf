locals {
  nginx_controller_components = [
    "controller",
    "controller.admissionWebhooks.patch",
  ]
  node_selectors = distinct(flatten([
    for component in local.nginx_controller_components : [
      for node_selector in var.node_selectors : {
        component = component
        key       = node_selector.key
        value     = node_selector.value
      }
    ]
  ]))
  tolerations = distinct(flatten([
    for component in local.nginx_controller_components : [
      for toleration in var.tolerations : {
        component = component
        key       = toleration.key
        operator  = toleration.operator
        effect    = toleration.effect
      }
    ]
  ]))
}

resource "helm_release" "nginx_ingress_controller" {
  count = var.nginx_controller != null ? 1 : 0

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  name       = "nginx-ingress-controller"
  version    = var.nginx_controller.version
  namespace  = var.nginx_controller.namespace

  set {
    name  = "controller.hostNetwork"
    value = true
  }
  set {
    name  = "controller.hostPort.enabled"
    value = true
  }

  dynamic "set" {
    for_each = local.node_selectors
    content {
      name  = "${set.value.component}.nodeSelector.${set.value.key}"
      value = set.value.value
    }
  }

  dynamic "set" {
    for_each = local.tolerations
    content {
      name  = "${set.value.component}.tolerations[0].key"
      value = set.value.key
    }
  }

  dynamic "set" {
    for_each = local.tolerations
    content {
      name  = "${set.value.component}.tolerations[0].operator"
      value = set.value.operator
    }
  }

  dynamic "set" {
    for_each = local.tolerations
    content {
      name  = "${set.value.component}.tolerations[0].effect"
      value = set.value.effect
    }
  }

  dynamic "set" {
    for_each = to_set(local.nginx_controller_components)
    content {
      name  = "${set.key}.nodeSelector.kubernetes\\.io/os"
      value = "linux"
    }
  }
}
