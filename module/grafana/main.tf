# create grafana loadbalancer
resource "aws_lb" "grafana-lb" {
  name            = "grafana-lb"
  internal        = false
  load_balancer_type = "application"
  subnets         = var.subnets
  security_groups = [var.grafana_sg_name]

  tags = {
    Name = "grafana-lb"
  }
}