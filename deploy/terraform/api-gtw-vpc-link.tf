resource "aws_security_group" "eks_vpc_link_sg" {
  name        = "${var.project_name}-eks-vpc-link-sg"
  description = "Security Group for API Gateway VPC Link"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from VPC CIDR"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    description = "Allow HTTP to ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = {
    Name = "${var.project_name}-eks-vpc-link-sg"
  }
}

resource "aws_apigatewayv2_vpc_link" "eks_vpc_link" {
  name               = "eks_vpc_link"
  security_group_ids = [aws_security_group.eks_vpc_link_sg.id]
  subnet_ids         = module.vpc.private_subnets
}

resource "aws_apigatewayv2_integration" "eks_integration" {
  api_id             = aws_apigatewayv2_api.gtw.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = aws_lb_listener.eks_alb_listener.arn
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.eks_vpc_link.id
}

resource "aws_apigatewayv2_route" "proxy_route" {
  api_id    = aws_apigatewayv2_api.gtw.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.eks_integration.id}"
}