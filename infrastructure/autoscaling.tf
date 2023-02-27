data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance" {
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  name = "${var.name}-ecs-runner"

  inline_policy {
    name = "logs"
    policy = data.aws_iam_policy_document.ecs_logs.json
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_runner" {
  name = "${var.name}-ecs-runner"
  role = aws_iam_role.ecs_instance.name
}

# runners for parties app resources
resource "aws_autoscaling_group" "ecs_runners" {
  name     = "${var.name}-ecs-runners"
  min_size = 0
  max_size = 2
  desired_capacity = 1

  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = aws_subnet.public.*.id
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

resource "aws_launch_configuration" "main" {
  name_prefix   = "${var.name}-ecs-runner-"
  image_id      = "ami-06c4db5ca8624041f"
  instance_type = "t4g.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_runner.name
  associate_public_ip_address = true
  user_data = <<-USER
  #!/bin/bash
  echo "ECS_CLUSTER=${aws_ecs_cluster.main.name}" >> /etc/ecs/ecs.config
  sudo yum install amazon-cloudwatch-agent
  USER

  lifecycle {
    create_before_destroy = true
  }
}