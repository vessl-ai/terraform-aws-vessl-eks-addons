resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.cert_manager.namespace
  version    = var.cert_manager.version

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_manifest" "issuer_staging" {
  depends_on = [helm_release.cert_manager]
  count      = var.cert_manager.create_staging_issuer ? 1 : 0
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "letsencrypt-staging"
      namespace = var.cert_manager.namespace
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = var.cert_manager.email
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = var.cert_manager.ingress_class_name
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "issuer_prod" {
  depends_on = [helm_release.cert_manager]
  count      = var.cert_manager.create_prod_issuer ? 1 : 0
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "letsencrypt-prod"
      namespace = var.cert_manager.namespace
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.cert_manager.email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = var.cert_manager.ingress_class_name
              }
            }
          }
        ]
      }
    }
  }
}