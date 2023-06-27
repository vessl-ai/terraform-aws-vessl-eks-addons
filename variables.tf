variable "cluster_name" {}
variable "cluster_version" {}
variable "cluster_oidc_provider_arn" {}
variable "cluster_oidc_issuer_url" {}

variable "external_dns" {
  type = optional(object({
    cluster_domain = string
    namespace      = optional(string, "kube-system")
    version        = optional(string, "1.13.0")
  }))
}

variable "nginx_controller" {
  type = optional(object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "4.7.0")
  }))
}

variable "load_balancer_controller" {
  type = optional(object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "1.4.5")
  }))
}

variable "cluster_autoscaler" {
  type = optional(object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "9.24.0")
  }))
}

variable "nvidia_gpu_operator" {
  type = optional(object({
    namespace = optional(string, "gpu-operator")
    version   = optional(string, "23.3.2")
  }))
}

variable "coredns" {
  type = optional(object({
    namespace  = string
    repository = string
    tag        = string
  }))
}

variable "kube_proxy" {
  type = optional(object({
    namespace  = string
    repository = string
    tag        = string
  }))
}

variable "vpc_cni" {
  type = optional(object({
    namespace  = string
    repository = string
    tag        = string
  }))
}

variable "ebs_csi_driver" {
  type = optional(object({
    namespace  = string
    repository = string
    tag        = string
  }))
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
    value    = string
    operator = optional(string)
    effect   = optional(string)
  }))
  default = []
}
