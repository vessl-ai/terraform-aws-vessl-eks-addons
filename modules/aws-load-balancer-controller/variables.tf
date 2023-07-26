variable "eks_cluster_name" {}
variable "oidc_provider_arn" {}
variable "oidc_issuer_url" {}
variable "k8s_namespace" {}
variable "helm_chart_version" {
  default = "1.4.5"
}

variable "node_selectors" {
  type = list(object({
    key   = string
    value = string
  }))
  default = [{
    key   = "v1.k8s.vessl.ai/dedicated"
    value = "manager"
  }]
}

variable "tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = optional(string)
  }))
  default = []
}

variable "tags" {
  default = {
    "vessl:managed" : "true",
  }
}
