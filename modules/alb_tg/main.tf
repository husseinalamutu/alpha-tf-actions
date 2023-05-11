# Create a target group for EC2 Instances
resource "aws_lb_target_group" "instance-tg" {
  name                          = "alb"
  port                          = 80
  protocol                      = "HTTP"
  target_type                   = "instance"
  vpc_id                        = var.vpc_id

  health_check {
    path                        = "/"
    protocol                    = "HTTP"
    enabled                     = true
    healthy_threshold           = 2
    unhealthy_threshold         = 2
    matcher                     = "200"
    port                        = 80
    timeout                     = 5
  }
}
