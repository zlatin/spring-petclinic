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