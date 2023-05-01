terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
  backend "s3" {
    bucket = "bahms-money"
    key    = "aws/bahms-money/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# modules
module "nginx_instance" {
  source = "./modules/ec2-instance"

  name          = "nginx-instance"
  ami           = data.aws_ami.nginx.id
  instance_type = "t2.micro"
  user_data     = file("${path.module}/files/nginx-user-data.sh")
  vpc_id        = "vpc-0123456789abcdef"
  subnet_id     = "subnet-0123456789abcdef"
}

module "apache_instance" {
  source = "./modules/ec2-instance"

  name          = "apache-instance"
  ami           = data.aws_ami.apache.id
  instance_type = "t2.micro"
  user_data     = file("${path.module}/files/apache-user-data.sh")
  vpc_id        = "vpc-0123456789abcdef"
  subnet_id     = "subnet-0123456789abcdef"
}

module "nginx_target_group" {
  source = "./modules/target-group"

  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0123456789abcdef"
}

module "apache_target_group" {
  source = "./modules/target-group"

  name     = "apache-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0123456789abcdef"
}

module "load_balancer" {
  source = "./modules/load-balancer"

  name                = "my-load-balancer"
  security_groups     = ["sg-0123456789abcdef"]
  subnets             = ["subnet-0123456789abcdef", "subnet-0123456789abcdeg"]
  target_group_arns   = [module.nginx_target_group.arn, module.apache_target_group.arn]
}

module "autoscaling_group" {
  source = "./modules/autoscaling-group"

  name                   = "my-autoscaling-group"
  launch_template_id     = "lt-0123456789abcdef"
  target_group_arn       = module.load_balancer.target_group_arn
  subnet_ids             = ["subnet-0123456789abcdef", "subnet-0123456789abcdef"]
  min_size               = 1
  max_size               = 3
  desired_capacity       = 2
  health_check_grace_period = 300
}


# # main.tf

# # Define the AWS provider
# provider "aws" {
#   region = "us-west-2"
# }

# Create two EC2 instances
# module "nginx_instance" {
#   source = "./modules/ec2-instance"

#   name            = "nginx-instance"
#   ami             = "ami-0c94855ba95c71c99"
#   instance_type   = "t2.micro"
#   user_data       = data.template_file.nginx_user_data.rendered
#   subnet_id       = "subnet-0123456789abcdef"
#   security_groups = ["sg-0123456789abcdef"]
# }

# module "apache_instance" {
#   source = "./modules/ec2-instance"

#   name            = "apache-instance"
#   ami             = "ami-0c94855ba95c71c99"
#   instance_type   = "t2.micro"
#   user_data       = data.template_file.apache_user_data.rendered
#   subnet_id       = "subnet-0123456789abcdef"
#   security_groups = ["sg-0123456789abcdef"]
# }

# # Define the user data for each instance
# data "template_file" "nginx_user_data" {
#   template = file("${path.module}/nginx_user_data.sh.tpl")

#   vars = {
#     nginx_version = "1.20.1"
#   }
# }

# data "template_file" "apache_user_data" {
#   template = file("${path.module}/apache_user_data.sh.tpl")

#   vars = {
#     apache_version = "2.4.41"
#   }
# }

# # Create a target group for the load balancer
# module "target_group" {
#   source = "./modules/target-group"

#   name     = "my-target-group"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = "vpc-0123456789abcdef"
# }

# # Create the load balancer
# module "load_balancer" {
#   source = "./modules/load-balancer"

#   name             = "my-load-balancer"
#   subnets          = ["subnet-0123456789abcdef", "subnet-0123456789abcdef"]
#   security_groups  = ["sg-0123456789abcdef"]
#   target_group_arn = module.target_group.target_group_arn
# }

# # Create the autoscaling group
# module "autoscaling_group" {
#   source = "./modules/autoscaling-group"

#   name              = "my-asg"
#   min_size          = 1
#   max_size          = 3
#   target_group_arn  = module.target_group.target_group_arn
#   instance_type     = "t2.micro"
# }
