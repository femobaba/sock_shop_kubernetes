# create stage loadbalancer
resource "aws_lb" "stage-lb" {
  name               = "stage-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [var.sg]

  tags = {
    Name = "stage-lb"
  }
}

resource "aws_lb_target_group" "stage-tg" {
  name     = var.target_name
  port     = var.http_proxy
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    healthy_threshold   = 4
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }
}

resource "aws_lb_listener" "stage-listener" {
  load_balancer_arn = aws_lb.stage-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stage-tg.arn
  }
}

resource "aws_lb_listener" "stage-listener2" {
  load_balancer_arn = aws_lb.stage-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy             = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stage-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "stage-attachment1" {
  target_group_arn = aws_lb_target_group.stage-tg.arn
  target_id        = var.instance1
  port             = 30001
}

resource "aws_lb_target_group_attachment" "stage-attachment2" {
  target_group_arn = aws_lb_target_group.stage-tg.arn
  target_id        = var.instance2
  port             = 30001
}

resource "aws_lb_target_group_attachment" "stage-attachmen3" {
  target_group_arn = aws_lb_target_group.stage-tg.arn
  target_id        = var.instance3
  port             = 30001
}
