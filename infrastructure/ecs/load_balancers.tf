# resource "aws_alb" "LoadBalancer" {
#   depends_on = [

#   ]
#   name               = "Petclinic"
#   subnets            = [aws_subnet.PublicSubnet1.id, aws_subnet.PublicSubnet2.id]
#   security_groups    = [aws_security_group.LoadBalancerSecurityGroup.id]
#   load_balancer_type = "application"
#   tags = {
#     Name = "Petclinic"
#   }
# }

# resource "aws_lb_target_group" "DefaultTargetGroup" {
#   name     = "Petclinic-default"
#   vpc_id   = aws_vpc.vpc.id
#   port     = 80
#   protocol = "HTTP"
# }

# resource "aws_alb_listener" "LoadBalancerListener" {
#   load_balancer_arn = aws_alb.LoadBalancer.arn
#   port              = 80
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.DefaultTargetGroup.arn
#   }
# }
# output "lb_listener" {
#   value = aws_alb_listener.LoadBalancerListener
# }

# output "lb_dns_address" {
#   value = aws_alb.LoadBalancer.dns_name
# }