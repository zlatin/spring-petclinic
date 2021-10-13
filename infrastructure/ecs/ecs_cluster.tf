resource "aws_ecs_cluster" "ECSCluster" {
  name = "Petclinic"
  # capacity_providers = [aws_ecs_capacity_provider.prov1.name]
}

# resource "aws_ecs_capacity_provider" "prov1" {
#   name = "prov1"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn = aws_autoscaling_group.ECSAutoScalingGroup.arn
#   }
# }

resource "aws_autoscaling_group" "ECSAutoScalingGroup" {

  depends_on = [
    aws_ecs_cluster.ECSCluster
  ]
  vpc_zone_identifier  = [aws_subnet.PrivateSubnet1.id, aws_subnet.PrivateSubnet2.id]
  launch_configuration = aws_launch_configuration.ECSLaunchConfiguration.name
  min_size             = 2
  max_size             = 3
  desired_capacity     = 2
  tag {
    key                 = "Name"
    value               = "Petclinic ECS host"
    propagate_at_launch = true
  }
  health_check_type = "EC2"
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

resource "aws_launch_configuration" "ECSLaunchConfiguration" {
  image_id             = data.aws_ami.ecs_ami.image_id
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.ECSHostSecurityGroup.id]
  iam_instance_profile = aws_iam_instance_profile.ECSInstanceProfile.name
  user_data            = "echo ECS_CLUSTER=Petclinic >> /etc/ecs/ecs.config"
}

resource "aws_iam_instance_profile" "ECSInstanceProfile" {
  path = "/"
  role = aws_iam_role.ECSRole.name
}

resource "aws_iam_role" "ECSRole" {
  path               = "/"
  name               = "Petclinic-ECSRole"
  assume_role_policy = <<EOF
{
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        }
    }]
}
EOF
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  inline_policy {
    name = "ecs-service"
    policy = jsonencode({
      "Version" = "2012-10-17",
      "Statement" = [{
        "Effect" = "Allow",
        "Action" = [
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:Submit*",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ],
        "Resource" = "*"
      }]
    })
  }
}

resource "aws_iam_role" "ECSServiceAutoScalingRole" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      },
    ]
  })
  path = "/"
  inline_policy {
    name = "ecs-service-autoscaling"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Resource = "*"
        Effect   = "Allow"
        Action = [
          "application-autoscaling:*",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:PutMetricAlarm",
          "ecs:DescribeServices",
          "ecs:UpdateService",
        ]
      }]
    })
  }
}


output "Cluster" {
  value = aws_ecs_cluster.ECSCluster.id
}
