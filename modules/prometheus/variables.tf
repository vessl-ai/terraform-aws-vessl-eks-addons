variable "namespace" {
  default = "prometheus"
}

variable "operator_crds" {
  type = object({
    enabled = bool
    version = string
  })
}

variable "operator_admission_webhook" {
  type = object({
    enabled = bool
    version = string
  })
}

variable "adapter" {
  type = object({
    enabled = bool
    version = string
    rules   = map(any)
  })
}

variable "tags" {
  type = map(string)
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
