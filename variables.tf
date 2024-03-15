variable "cluster_name" {}
variable "cluster_version" {}
variable "cluster_oidc_provider_arn" {}
variable "cluster_oidc_issuer_url" {}

variable "external_dns" {
  type = object({
    cluster_domain             = string
    cluster_hosted_zone_domain = optional(string, "")
    extra_domains              = optional(list(string), [])
    namespace                  = optional(string, "kube-system")
    version                    = optional(string, "1.14.3")
    sources                    = optional(list(string), ["service"])
    tcp_nodeport               = optional(bool, false)
    // https://github.com/kubernetes-sigs/external-dns/blob/master/charts/external-dns/values.yaml
    helm_values = optional(map(any), {})
  })
  default = null
}

variable "ingress_nginx" {
  type = object({
    namespace           = optional(string, "kube-system")
    create_namespace    = optional(bool, false)
    version             = optional(string, "4.10.0")
    service_annotations = optional(map(string), {})
    ssl_termination     = optional(bool, false)
    extra_chart_values  = optional(list(string), [])
  })
  default = null
}

variable "load_balancer_controller" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "1.7.1")
  })
  default = null
}

variable "cluster_autoscaler" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "9.35.0")
  })
  default = null
}

variable "coredns" {
  type = object({
    version = optional(string, "v1.11.1-eksbuild.6")
  })
  default = null
}

variable "kube_proxy" {
  type = object({
    version = optional(string, "v1.29.1-eksbuild.2")
  })
  default = null
}

variable "vpc_cni" {
  type = object({
    version = optional(string, "v1.16.3-eksbuild.2")
  })
  default = null
}

variable "ebs_csi_driver" {
  type = object({
    version            = optional(string, "v1.28.0-eksbuild.1")
    storage_class_name = optional(string, "vessl-ebs")
  })
  default = null
}

variable "metrics_server" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "3.12.0")
    // https://github.com/kubernetes-sigs/metrics-server/blob/master/charts/metrics-server/values.yaml
    helm_values = optional(any, {})
  })
  default = null
}

variable "node_affinity" {
  type = list(object({
    key      = string
    operator = string
    values   = optional(list(string))
  }))
  default = [{
    key      = "v1.k8s.vessl.ai/dedicated"
    operator = "In"
    values   = ["manager"]
  }]
}

variable "tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = optional(string)
  }))
  default = [{
    key      = "v1.k8s.vessl.ai/dedicated"
    operator = "Exists"
    effect   = "NoSchedule"
  }]
}

variable "tags" {
  type = map(string)
  default = {
    "vessl:managed" : "true",
  }
}
