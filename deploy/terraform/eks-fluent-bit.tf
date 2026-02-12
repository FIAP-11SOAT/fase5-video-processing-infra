# IAM Policy Document for Fluent Bit assume role
data "aws_iam_policy_document" "fluent_bit_assume_role" {
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
      values   = ["system:serviceaccount:amazon-cloudwatch:fluent-bit"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# IAM Role for Fluent Bit
resource "aws_iam_role" "fluent_bit_role" {
  name               = "${var.project_name}-fluent-bit-role"
  description        = "IAM role for AWS Fluent Bit"
  assume_role_policy = data.aws_iam_policy_document.fluent_bit_assume_role.json

  tags = {
    Name = "${var.project_name}-fluent-bit-role"
  }
}

# IAM Policy for Fluent Bit to write to CloudWatch Logs
resource "aws_iam_policy" "fluent_bit_policy" {
  name        = "${var.project_name}-fluent-bit-policy"
  path        = "/"
  description = "IAM policy for AWS Fluent Bit to write logs to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-fluent-bit-policy"
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "fluent_bit_attach" {
  role       = aws_iam_role.fluent_bit_role.name
  policy_arn = aws_iam_policy.fluent_bit_policy.arn
}


# Kubernetes Namespace for Fluent Bit
resource "kubernetes_namespace" "amazon_cloudwatch" {
  metadata {
    name = "amazon-cloudwatch"
    labels = {
      name = "amazon-cloudwatch"
    }
  }

  depends_on = [aws_eks_cluster.eks_cluster]
}

# Kubernetes Service Account for Fluent Bit
resource "kubernetes_service_account" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
    labels = {
      "app.kubernetes.io/component" = "fluent-bit"
      "app.kubernetes.io/name"      = "fluent-bit"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.fluent_bit_role.arn
    }
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    kubernetes_namespace.amazon_cloudwatch
  ]
}

# Helm Release for AWS Fluent Bit
resource "helm_release" "aws_fluent_bit" {
  name       = "aws-for-fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = kubernetes_namespace.amazon_cloudwatch.metadata[0].name

  set = [
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.fluent_bit.metadata[0].name
    },
    {
      name  = "cloudWatchLogs.enabled"
      value = "true"
    },
    {
      name  = "cloudWatchLogs.region"
      value = data.aws_region.current.region
    },
    {
      name  = "cloudWatchLogs.logGroupTemplate"
      value = "/aws/eks/${aws_eks_cluster.eks_cluster.name}/$kubernetes['namespace_name']"
    },
    {
      name  = "cloudWatchLogs.logStreamTemplate"
      value = "$kubernetes['pod_name'].$kubernetes['container_name']"
    },
    {
      name  = "cloudWatchLogs.autoCreateGroup"
      value = "true"
    },
    {
      name  = "firehose.enabled"
      value = "false"
    },
    {
      name  = "kinesis.enabled"
      value = "false"
    },
    {
      name  = "elasticsearch.enabled"
      value = "false"
    }
  ]

  depends_on = [
    aws_eks_node_group.node_group,
    kubernetes_service_account.fluent_bit,
    aws_iam_openid_connect_provider.cluster_oidc,
    aws_iam_role_policy_attachment.fluent_bit_attach
  ]
}
