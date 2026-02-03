# resource "aws_apigatewayv2_vpc_link" "eks_vpc_link" {
#   name               = "eks_vpc_link"
#   security_group_ids = [aws_security_group.vpc_link_sg.id]
#   subnet_ids         = module.vpc.private_subnets
# }
#
# resource "aws_apigatewayv2_integration" "eks_integration" {
#   api_id             = aws_apigatewayv2_api.gtw.id
#   integration_type   = "HTTP_PROXY"
#   integration_method = "ANY"
#   integration_uri    = aws_lb_listener.eks_alb_listener.arn
#   connection_type    = "VPC_LINK"
#   connection_id      = aws_apigatewayv2_vpc_link.eks_vpc_link.id
# }
#
# resource "aws_apigatewayv2_route" "proxy_route" {
#   api_id    = aws_apigatewayv2_api.gtw.id
#   route_key = "ANY /{proxy+}"
#   target    = "integrations/${aws_apigatewayv2_integration.eks_integration.id}"
# }