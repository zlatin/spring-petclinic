module "cluster" {
  source = "../ecs"

}

variable "task_count" {
  type    = number
  default = 1
}

variable "docker_image" {
  type    = string
  default = "jbrisbin/spring-petclinic"
}

resource "aws_ecs_service" "Service" {
  name = "Petclinic-service"
  depends_on = [
    aws_iam_role.ServiceRole
  ]
  cluster         = "Petclinic"
  iam_role        = aws_iam_role.ServiceRole.arn
  desired_count   = var.task_count
  task_definition = aws_ecs_task_definition.TaskDefinition.arn
  load_balancer {
    container_name   = "petclinic"
    container_port   = 8080
    target_group_arn = aws_alb_target_group.TargetGroup.arn
  }
}

resource "aws_ecs_task_definition" "TaskDefinition" {
  family = "petclinic"
  container_definitions = jsonencode([
    {
      name      = "petclinic"
      image     = var.docker_image
      essential = true
      memory    = 250
      portMappings = [
        {
          containerPort = 8080
        }
      ]
    }
  ])
}

resource "aws_alb_target_group" "TargetGroup" {
  vpc_id   = module.cluster.vpc_id
  port     = 80
  protocol = "HTTP"
}

resource "aws_lb_listener_rule" "ListenerRule" {
  listener_arn = module.cluster.lb_listener.arn
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.TargetGroup.arn
  }
}
resource "aws_iam_role" "ServiceRole" {
  name = "ecs-service-Petclinic"
  path = "/"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      "Statement" : [
        {
          "Effect" = "Allow"
          "Principal" = {
            "Service" = ["ecs.amazonaws.com"]
          }
          "Action" = ["sts:AssumeRole"]
        },
      ]
    }
  )
  inline_policy {
    name = "ecs-service-Petclinic"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ec2:AuthorizeSecurityGroupIngress",
            "ec2:Describe*",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:Describe*",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "elasticloadbalancing:DeregisterTargets",
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:RegisterTargets"
          ]
          Resource = "*"
        },
      ]
    })
  }
}

output "lb_address" {
  value = module.cluster.lb_dns_address
}
