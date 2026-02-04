resource "aws_lb" "eks_internal" {
  name               = md5("${var.project_name}-alb-internal")
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_internal_sg.id]
  subnets            = module.vpc.private_subnets

  tags = {
    Name = "${var.project_name}-alb-internal"
    "ingress.k8s.aws/resource" : "LoadBalancer"
    "ingress.k8s.aws/stack" : "k8s-shared-internal-alb-use1"
    # "elbv2.k8s.aws/cluster" : aws_eks_cluster.eks_cluster.name
  }
}

resource "aws_lb_listener" "eks_alb_listener" {
  load_balancer_arn = aws_lb.eks_internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Default response from ALB"
      status_code  = "404"
    }
  }
}

resource "aws_security_group" "alb_internal_sg" {
  name        = "${var.project_name}-eks-alb-sg"
  description = "Security Group for internal ALB in EKS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow HTTP from VPC Link SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_vpc_link_sg.id]
  }

  egress {
    description = "Allow all outbound traffic to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = {
    Name = "${var.project_name}-alb-internal-sg"
    Tier = "alb/internal"
  }
}