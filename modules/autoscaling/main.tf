resource "aws_launch_configuration" "asg-launch-config" {
  name_prefix     = format("%s-%s-%s", var.appname, var.env, "launch-config")
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = var.security_groups

  user_data = var.user_data_base64

  lifecycle {
    create_before_destroy = false
  }
}

/* data "aws_ami" "ubuntu" {} */

# Launch Template Resource
/* resource "aws_launch_template" "my_launch_template" {
  name_prefix     = format("%s-%s-%s", var.appname, var.env, "launch_template")
  description   = "My Launch Template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  user_data              = var.user_data_base64
  update_default_version = true
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "my-asg-instance"
    }
  }
} */

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.asg-launch-config.id
  /* launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = aws_launch_template.my_launch_template.latest_version
  } */

  vpc_zone_identifier = var.vpc_zone_identifier
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  health_check_type   = "ELB"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

/* -------------auto-scaling0policy-------------------------------- */

resource "aws_autoscaling_policy" "simple_scaling_policy" {
  count                  = var.policy_type == "SimpleScaling" ? 1 : 0
  name                   = "simple_scaling_policy"
  scaling_adjustment     = 3
  policy_type            = var.policy_type
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "target_tracking_policy" {
  count                     = var.policy_type == "target_tracking_policy" ? 1 : 0
  name                      = "target_tracking_policy"
  policy_type               = var.policy_type
  estimated_instance_warmup = 60
  target_tracking_configuration {
    target_value = 70
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "example" {
  count                  = var.policy_type == "StepScaling" ? 1 : 0
  name                   = "example-policy"
  policy_type            = var.policy_type
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 10
  }

  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = 10
    metric_interval_upper_bound = null
  }
}
