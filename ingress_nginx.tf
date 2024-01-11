locals {
  ingress_nginx_components = [
    "controller",
    "controller.admissionWebhooks.patch",
  ]
  ingress_nginx_node_selectors = distinct(flatten([
    for component in local.ingress_nginx_components : [
      for node_selector in var.node_selectors : {
        component = component
        key       = node_selector.key
        value     = node_selector.value
      }
    ]
  ]))
  ingress_nginx_tolerations = distinct(flatten([
    for component in local.ingress_nginx_components : [
      for toleration in var.tolerations : {
        component = component
        key       = toleration.key
        operator  = toleration.operator
        effect    = toleration.effect
      }
    ]
  ]))
  service_target_ports = try(var.ingress_nginx.ssl_termination, false) ? {
    http  = "http",
    https = "http",
  } : {}
}

resource "helm_release" "ingress_nginx" {
  count = var.ingress_nginx != null ? 1 : 0

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  version    = var.ingress_nginx.version
  namespace  = var.ingress_nginx.namespace

  dynamic "set" {
    for_each = local.service_target_ports
    content {
      name  = "controller.service.targetPorts.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.ingress_nginx.service_annotations
    content {
      name  = "controller.service.annotations.${replace(set.key, ".", "\\.")}"
      value = replace(set.value, ",", "\\,")
    }
  }

  dynamic "set" {
    for_each = local.ingress_nginx_node_selectors
    content {
      name  = "${set.value.component}.nodeSelector.${replace(set.value.key, ".", "\\.")}"
      value = set.value.value
    }
  }

  dynamic "set" {
    for_each = local.ingress_nginx_tolerations
    content {
      name  = "${set.value.component}.tolerations[0].key"
      value = set.value.key
    }
  }

  dynamic "set" {
    for_each = local.ingress_nginx_tolerations
    content {
      name  = "${set.value.component}.tolerations[0].operator"
      value = set.value.operator
    }
  }

  dynamic "set" {
    for_each = local.ingress_nginx_tolerations
    content {
      name  = "${set.value.component}.tolerations[0].effect"
      value = set.value.effect
    }
  }

  dynamic "set" {
    for_each = toset(local.ingress_nginx_components)
    content {
      name  = "${set.key}.nodeSelector.kubernetes\\.io/os"
      value = "linux"
    }
  }

  values = var.ingress_nginx.extra_chart_values
}
