resource "aws_lb" "alb" {
  count              = var.type == "application" ? 1 : 0
  name               = format ( "%s-%s-%s",var.appname,var.env,"alb")
  internal           = var.internal
  load_balancer_type = var.type
  security_groups    = var.security_groups
  subnets         = var.subnets
  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.log-bucket.id
    prefix  = var.appname
    enabled = true
  }
  tags = merge(var.tags, { Name = format("%s-%s-alb", var.appname, var.env) })
}

resource "aws_lb" "nlb" {
  count              = var.type == "network" ? 1 : 0
  name               = format ( "%s-%s-%s",var.appname,var.env,"nlb")
  internal           = var.internal
  load_balancer_type = var.type
  subnets            = var.subnets
  enable_deletion_protection = false
  tags = merge(var.tags, { Name = format("%s-%s-nlb", var.appname, var.env) })
}

resource "aws_s3_bucket" "log-bucket" {
  bucket = "logbucket-${var.appname}-${var.env}-${random_string.random.id}"
}

resource "aws_s3_bucket_policy" "log-bucket-policy" {
  bucket = aws_s3_bucket.log-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
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
  length           = 5
  special          = false
  upper            = false
}