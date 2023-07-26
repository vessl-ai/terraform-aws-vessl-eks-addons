variable "cluster_name" {}
variable "cluster_version" {}
variable "cluster_oidc_provider_arn" {}
variable "cluster_oidc_issuer_url" {}

variable "external_dns" {
  type = object({
    cluster_domain = string
    namespace      = optional(string, "kube-system")
    version        = optional(string, "1.13.0")
    sources        = optional(list(string), ["service"])
    helm_values    = optional(map(any), {})
  })
  default = null
}

variable "ingress_nginx" {
  type = object({
    namespace = optional(string, "kube-system")
    version   = optional(string, "4.7.0")
    // See: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/service/annotations
    service_annotations = optional(map(string), {
      "service.beta.kubernetes.io/aws-load-balancer-type"                    = "external"
      "service.beta.kubernetes.io/aws-load-balancer-scheme"                  = "internet-facing"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"         = "ip"
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "tcp"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"               = "443"
      "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "60"
      "service.beta.kubernetes.io/aws-load-balancer-attributes"              = "load_balancing.cross_zone.enabled=true"
      // "service.beta.kubernetes.io/aws-load-balancer-subnets"  = join(",", subnet_ids)
      // "service.beta.kubernetes.io/aws-load-balancer-ssl-cert" = aws_acm_certificate.cert.arn
      // "external-dns.alpha.kubernetes.io/hostname"             = "*.example.com" // => To make the dns record point to the NLB created by this service
    })
    ssl_termination = optional(bool, true)
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
    version            = optional(string, "v1.20.0-eksbuild.1")
    storage_class_name = optional(string, "vessl-ebs")
  })
  default = null
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
