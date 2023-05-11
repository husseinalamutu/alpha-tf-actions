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