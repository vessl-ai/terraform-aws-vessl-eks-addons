locals {
  tags = merge(var.tags, {
    "vessl:component" = "addon/cert-manager",
  })
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# ----------------------------------------------------
# IAM Role to use for the cert-manager service account
# ----------------------------------------------------
resource "aws_iam_role" "cert-manager" {
  name               = "${var.cluster_name}-cert-manager-irsa"
  assume_role_policy = data.aws_iam_policy_document.cert-manager_irsa.json
  description        = "AWS IAM Role for the Kubernetes service account kube-system:cert-manager"
  tags               = local.tags
}

# Assume role policy for IRSA
data "aws_iam_policy_document" "cert-manager_irsa" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values = [
        "system:serviceaccount:kube-system:cert-manager",
      ]
    }
  }
}

# ------------------------------------
# IAM policy for cert-manager IAM role
# ------------------------------------
data "aws_iam_policy_document" "cert-manager" {
  statement {
    sid       = "GetChange"
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    sid    = "ResourceRecordSetsCreateList"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*",
    ]
  }
  statement {
    sid       = "ListHostedZonesByName"
    effect    = "Allow"
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cert-manager" {
  name        = "${var.cluster_name}-cert-manager"
  path        = "/"
  description = "AWS IAM Policy for the Kubernetes service account kube-system:cert-manager"
  policy      = data.aws_iam_policy_document.cert-manager.json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "cert-manager" {
  role       = aws_iam_role.cert-manager.name
  policy_arn = aws_iam_policy.cert-manager.arn
}

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

resource "kubernetes_manifest" "cluster_issuer_staging" {
  depends_on = [helm_release.cert_manager]
  count      = var.cert_manager.create_staging_cluster_issuer ? 1 : 0
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
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
            selector = {
              dnsZones = [
                var.cert_manager.dns_zone
              ]
            }
            dns01 = {
              route53 = {
                region       = var.cert_manager.hosted_zone_region
                hostedZoneID = var.cert_manager.hosted_zone_id
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "cluster_issuer_prod" {
  depends_on = [helm_release.cert_manager]
  count      = var.cert_manager.create_prod_cluster_issuer ? 1 : 0
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
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
            selector = {
              dnsZones = [
                var.cert_manager.dns_zone
              ]
            }
            dns01 = {
              route53 = {
                region       = var.cert_manager.hosted_zone_region
                hostedZoneID = var.cert_manager.hosted_zone_id
              }
            }
          }
        ]
      }
    }
  }
}