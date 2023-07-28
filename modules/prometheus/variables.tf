variable "namespace" {
  default = "prometheus"
}

variable "operator_crds" {
  type = object({
    enable  = bool
    version = string
  })
  default = {
    enable  = true
    version = "5.0.0"
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to put on AWS resources (e.g. IAM role, owner, etc.)"
  default = {
    "terraform" = "true"
  }
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
