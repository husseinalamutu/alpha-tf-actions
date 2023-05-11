# Load Balancer configuration for Instances
resource "aws_lb" "instance-lb" {
  name                          = "${var.name_prefix}-lb"
  internal                      = false
  load_balancer_type            = "application"
  ip_address_type               = "ipv4"
  security_groups               = "${var.security_group}"
  subnets                       = var.public_subnets
  enable_deletion_protection    = false
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn            = aws_lb.instance-lb.arn
  port                         = "80"
  protocol                     = "HTTP"

  default_action {
    type                       = "forward"
    target_group_arn           = var.lb_tg_arn
  }
}
