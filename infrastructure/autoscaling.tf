data "aws_ami" "ecs_runner" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }
}

# runners for parties app resources
resource "aws_autoscaling_group" "ecs_runners" {
  name     = "${var.name}-ecs-runners"
  min_size = 0
  max_size = 2

  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = aws_subnet.public.*.id
}

resource "aws_launch_configuration" "main" {
  name_prefix   = "${var.name}-ecs-runner-"
  image_id      = data.aws_ami.ecs_runner.id
  instance_type = "t4g.micro"

  lifecycle {
    create_before_destroy = true
  }
}