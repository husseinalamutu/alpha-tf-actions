# modules/autoscaling-group/main.tf

variable "name" {
  description = "Name of the autoscaling group"
  type        = string
  default     = "my-asg"
}

variable "min_size" {
  description = "Minimum number of instances in the autoscaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the autoscaling group"
  type        = number
  default     = 3
}

variable "target_group_arn" {
  description = "ARN of the target group associated with the autoscaling group"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for the autoscaling group"
  type        = string
  default     = "t2.micro"
}

resource "aws_autoscaling_group" "asg" {
  name                      = var.name
  max_size                  = var.max_size
  min_size                  = var.min_size
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  tags = {
    Name = var.name
  }
}

resource "aws_launch_template" "launch_template" {
  image_id = "ami-0c94855ba95c71c99"
  instance_type = var.instance_type
}

output "autoscaling_group_name" {
  description = "Name of the autoscaling group"
  value       = aws_autoscaling_group.asg.name
}
