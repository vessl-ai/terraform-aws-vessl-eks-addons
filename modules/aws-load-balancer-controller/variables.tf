variable "eks_cluster_name" {}
variable "oidc_provider_arn" {}
variable "oidc_issuer_url" {}
variable "k8s_namespace" {}
variable "helm_chart_version" {
  default = "1.4.5"
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
