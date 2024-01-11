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
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name = "letsencrypt-staging"
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