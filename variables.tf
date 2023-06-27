variable "cluster_name" {}
variable "cluster_version" {}
variable "cluster_oidc_provider_arn" {}
variable "cluster_oidc_issuer_url" {}

variable "external_dns" {
  type = object({
    cluster_domain = string
    namespace      = optional(string, "kube-system")
    version        = optional(string, "1.13.0")
  })
  default = null
}

variable "nginx_controller" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "4.7.0")
  })
  default = null
}

variable "load_balancer_controller" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "1.4.5")
  })
  default = null
}

variable "cluster_autoscaler" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "9.24.0")
  })
  default = null
}

variable "nvidia_gpu_operator" {
  type = object({
    namespace = optional(string, "gpu-operator")
    version   = optional(string, "23.3.2")
  })
  default = null
}

variable "coredns" {
  type = object({
    version = optional(string, "v1.9.3-eksbuild.5")
  })
  default = null
}

variable "kube_proxy" {
  type = object({
    version = optional(string, "v1.25.11-eksbuild.1")
  })
  default = null
}

variable "vpc_cni" {
  type = object({
    version = optional(string, "v1.13.2-eksbuild.1")
  })
  default = null
}

variable "ebs_csi_driver" {
  type = object({
    version = optional(string, "v1.19.0-eksbuild.2")
  })
  default = null
}

variable "node_selectors" {
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

variable "tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = optional(string)
  }))
  default = [{
    key      = "app.vessl.ai/dedicated"
    operator = "Exists"
    effect   = "NoSchedule"
  }]
}
