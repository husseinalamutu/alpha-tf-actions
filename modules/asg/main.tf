# Create an Auto scaling group for spin up required instances
resource "aws_autoscaling_group" "instance-asg" {
  name                      = "asg"
  desired_capacity          = 2
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = ["${var.tg_arn}"]
  vpc_zone_identifier       = var.lb_subnets

  launch_template {
    id      = var.lt_instance_id
    version = "$Latest"
  }
}