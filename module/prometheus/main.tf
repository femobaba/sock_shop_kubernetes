# create prometheus loadbalancer
resource "aws_lb" "prometheus-lb" {
  name            = "prometheus-lb"
  internal        = false
  load_balancer_type = "application"
  subnets         = var.subnets
  security_groups = [var.prometheus_sg_name]

  tags = {
    Name = "prometheus-lb"
  }
}