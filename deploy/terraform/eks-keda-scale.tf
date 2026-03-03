# IAM Policy Document for KEDA operator assume role (IRSA)
data "aws_iam_policy_document" "keda_operator_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.cluster_oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:keda:keda-operator"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# IAM Role for KEDA operator
resource "aws_iam_role" "keda_operator_role" {
  name               = "${var.project_name}-keda-operator-role"
  description        = "IAM role for KEDA operator (IRSA)"
  assume_role_policy = data.aws_iam_policy_document.keda_operator_assume_role.json

  tags = {
    Name = "${var.project_name}-keda-operator-role"
  }
}

# IAM Policy for KEDA operator - permissões mínimas para scalers AWS comuns
# Ajuste conforme os scalers que você realmente usa (SQS, CloudWatch, etc.)
resource "aws_iam_policy" "keda_operator_policy" {
  name        = "${var.project_name}-keda-operator-policy"
  path        = "/"
  description = "IAM policy for KEDA operator to access AWS services (SQS, CloudWatch, etc.)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ListQueues",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          # Adicione mais conforme necessário, ex.:
          # "dynamodb:DescribeTable", "kinesis:ListShards", "s3:ListBucket", etc.
        ]
        Resource = "*" # Restrinja por ARN quando possível (melhor prática)
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-keda-operator-policy"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "keda_operator_attach" {
  role       = aws_iam_role.keda_operator_role.name
  policy_arn = aws_iam_policy.keda_operator_policy.arn
}

# Kubernetes Namespace for KEDA
resource "kubernetes_namespace" "keda" {
  metadata {
    name = "keda"
    labels = {
      name = "keda"
    }
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}

# Kubernetes Service Account for KEDA operator (com IRSA annotation)
resource "kubernetes_service_account" "keda_operator" {
  metadata {
    name      = "keda-operator"
    namespace = kubernetes_namespace.keda.metadata[0].name
    labels = {
      "app.kubernetes.io/component"  = "operator"
      "app.kubernetes.io/instance"   = "keda"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "keda-operator"
      "app.kubernetes.io/part-of"    = "keda-operator"
      "app.kubernetes.io/version"    = "2.19.0"
      "helm.sh/chart"                = "keda-2.19.0"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"     = aws_iam_role.keda_operator_role.arn
      "meta.helm.sh/release-name"      = "keda"
      "meta.helm.sh/release-namespace" = "keda"
    }
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    kubernetes_namespace.keda
  ]
}

# Helm Release for KEDA
resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = "2.19.0" # ou use ~> 2.19 se quiser minor updates
  namespace  = kubernetes_namespace.keda.metadata[0].name

  set = [
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.keda_operator.metadata[0].name
    },
    {
      name  = "operator.replicaCount"
      value = "1"
    },
    {
      name  = "metricsServer.replicaCount"
      value = "1"
    },
    {
      name  = "operator.resources.requests.cpu"
      value = "100m"
    },
    {
      name  = "operator.resources.requests.memory"
      value = "128Mi"
    },
    {
      name  = "operator.resources.limits.cpu"
      value = "500m"
    },
    {
      name  = "operator.resources.limits.memory"
      value = "512Mi"
    },
    {
      name  = "metricsServer.resources.requests.cpu"
      value = "100m"
    },
    {
      name  = "metricsServer.resources.requests.memory"
      value = "128Mi"
    },
    {
      name  = "metricsServer.resources.limits.cpu"
      value = "500m"
    },
    {
      name  = "metricsServer.resources.limits.memory"
      value = "512Mi"
    }
  ]

  depends_on = [
    aws_eks_node_group.node_group, # ajuste se o seu node group tiver nome diferente
    kubernetes_service_account.keda_operator,
    aws_iam_openid_connect_provider.cluster_oidc,
    aws_iam_role_policy_attachment.keda_operator_attach
  ]
}