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