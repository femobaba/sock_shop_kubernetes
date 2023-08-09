# create production loadbalancer
resource "aws_lb" "prod-lb" {
  name               = "prod-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [var.sg]

  tags = {
    Name = "prod-lb"
  }
}