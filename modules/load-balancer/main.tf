variable "name" {
  type        = string
  description = "The name of the load balancer"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets to use for the load balancer"
}

resource "aws_lb" "load_balancer" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]

  dynamic "subnet_mapping" {
    for_each = var.subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = {
    Name = var.name
  }
}


# modules/load-balancer/main.tf

variable "name" {
  description = "Name of the load balancer"
  type        = string
  default     = "my-load-balancer"
}

variable "subnets" {
  description = "List of subnet IDs in which to create the load balancer"
  type        = list(string)
  default     = ["subnet-0123456789abcdef", "subnet-0123456789abcdef"]
}

variable "security_groups" {
  description = "List of security group IDs to associate with the load balancer"
  type        = list(string)
  default     = ["sg-0123456789abcdef"]
}

variable "target_group_arn" {
  description = "ARN of the target group to which to route traffic"
  type        = string
  default     = ""
}

resource "aws_lb" "this" {
  name               = var.name
  subnets            = var.subnets
  security_groups    = var.security_groups
  internal           = false

  load_balancer_type = "application"

  tags = {
    Name = var.name
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = var.target_group_arn
    type             = "forward"
  }
}
# modules/autoscaling-group/main.tf

variable "name" {
  description = "Name of the autoscaling group"
  type        = string
  default     = "my-autoscaling-group"
}

variable "launch_template_id" {
  description = "ID of the launch template to use for the instances"
  type        = string
  default     = "lt-0123456789abcdef"
}

variable "target_group_arn" {
  description = "ARN of the target group to which to register the instances"
  type        = string
  default     = ""
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

variable "desired_capacity" {
  description = "Desired number of instances in the autoscaling group"
  type        = number
  default     = 2
}

variable "health_check_grace_period" {
  description = "Grace period (in seconds) for health checks after instances are launched"
  type        = number
  default     = 300
}

variable "health_check_type" {
  description = "Type of health checks to perform on instances in the autoscaling group"
  type        = string
  default     = "EC2"
}

variable "tags" {
  description = "Map of tags to assign to the instances in the autoscaling group"
  type        = map(string)
  default     = {
    Name = "my-instance"
  }
}

resource "aws_autoscaling_group" "this" {
  name                 = var.name
  launch_template      = [{ "id" = var.launch_template_id }]
  target_group_arns    = [var.target_group_arn]
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  health_check_grace_period = var.health_check_grace_period
  health_check_type    = var.health_check_type
  vpc_zone_identifier  = var.subnet_ids
  tags                 = var.tags

  depends_on = [
    aws_lb_target_group_attachment.this
  ]
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = var.target_group_arn
  target_id        = aws_autoscaling_group.this.id
  port             = 80
}
