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
    version                    = optional(string, "1.15.0")
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
    version             = optional(string, "4.11.3")
    service_annotations = optional(map(string), {})
    service_type        = optional(string, "LoadBalancer")
    ssl_termination     = optional(bool, false)
    helm_values         = optional(any, {})
  })
  default = null
}

variable "load_balancer_controller" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "1.9.0")
  })
  default = null
}

variable "cluster_autoscaler" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "9.43.1")
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

variable "pod_identity_agent" {
  type = object({
    version = optional(string, "v1.3.7-eksbuild.2")
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

variable "use_gp2" {
  type    = bool
  default = false
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
