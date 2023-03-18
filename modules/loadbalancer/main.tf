resource "aws_lb" "alb" {
  count                      = var.type == "application" ? 1 : 0
  name                       = format("%s-%s-%s", var.appname, var.env, "alb")
  internal                   = var.internal
  load_balancer_type         = var.type
  security_groups            = var.security_groups
  subnets                    = var.subnets
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.log-bucket.id
    prefix  = var.appname
    enabled = true
  }
  tags = merge(var.tags, { Name = format("%s-%s-alb", var.appname, var.env) })
}

resource "aws_lb" "nlb" {
  count                      = var.type == "network" ? 1 : 0
  name                       = format("%s-%s-%s", var.appname, var.env, "nlb")
  internal                   = var.internal
  load_balancer_type         = var.type
  subnets                    = var.subnets
  enable_deletion_protection = false
  tags                       = merge(var.tags, { Name = format("%s-%s-nlb", var.appname, var.env) })
}

resource "aws_s3_bucket" "log-bucket" {
  bucket        = "logbucket-${var.appname}-${var.env}-${random_string.random.id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "log-bucket-policy" {
  bucket = aws_s3_bucket.log-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.log-bucket.arn}/*"
      }
    ]
  })
}

resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}

resource "aws_lb_target_group" "mytg" {
  name     = format("%s-%s-%s", var.appname, var.env, "mytg")
  port     = 80
  protocol = var.type == "application" ? "HTTP" : "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "lb-listener" {
  port     = 80
  protocol = var.type == "application" ? "HTTP" : "TCP"


  dynamic "default_action" {
    for_each = var.type == "application" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.mytg.arn
    }
  }

  dynamic "default_action" {
    for_each = var.type == "network" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.mytg.arn
    }
  }

  load_balancer_arn = element(var.type == "application" ? aws_lb.alb[*].arn : aws_lb.nlb[*].arn, 0)

}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = var.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.mytg.arn
}