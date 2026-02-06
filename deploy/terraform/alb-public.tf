resource "aws_lb" "alb_public" {
  name               = md5("${var.project_name}-alb-public")
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_public_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb-public"
    "ingress.k8s.aws/resource" : "LoadBalancer"
    "ingress.k8s.aws/stack" : "k8s-application-public-alb-use1"
    "elbv2.k8s.aws/cluster" : aws_eks_cluster.eks_cluster.name
  }
}

resource "aws_security_group" "alb_public_sg" {
  name        = "${var.project_name}-alb-public-sg"
  description = "Security Group for public ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-public-sg"
    Tier = "alb/public"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb_public.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.front.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Public OK"
      status_code  = "200"
    }
  }
}

resource "cloudflare_dns_record" "alb_public_a" {
  zone_id = local.aws_master_secrets["CLOUDFLARE_ZONE_ID"]
  name    = "@"
  type    = "CNAME"
  ttl     = 1
  content = aws_lb.alb_public.dns_name
  proxied = false
}
