data "http" "cognito_jwks" {
  url = "https://${aws_cognito_user_pool.this.endpoint}/.well-known/jwks.json"

  request_headers = {
    Accept = "application/json"
  }

  depends_on = [
    aws_cognito_user_pool.this
  ]
}

data "aws_eks_cluster_auth" "auth" {
  name = aws_eks_cluster.eks_cluster.name
}

data "tls_certificate" "cluster_oidc" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

