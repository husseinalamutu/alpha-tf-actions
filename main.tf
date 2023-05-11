# Data source for VPC
data "aws_vpc" "default_vpc" {
  default = true
}

# Data source for Subnets
data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# A data source template for nginx server
data "template_file" "nginx-data-script" {
  template = file("./user-data.tpl")
}

module "security_group" {
  source                       = "./modules/sg"

  sg_name_prefix               = "instance-sg"
  vpc_id                       = data.aws_vpc.default_vpc.id
}

module "load_balancer" {
  source                       = "./modules/alb"

  name_prefix                  = "server"
  security_group               = [module.security_group.sg-instance]
  public_subnets               = data.aws_subnets.subnets.ids
  lb_tg_arn                    = module.load_balancer_target_group.alb-tg
}

# Alb_target_group
module "load_balancer_target_group" {
  source                       = "./modules/alb_tg"

  vpc_id                       = data.aws_vpc.default_vpc.id
}

module "auto_scaling" {
  source                       = "./modules/asg"

  tg_arn                       = module.load_balancer_target_group.alb-tg
  lb_subnets                   = data.aws_subnets.subnets.ids
  lt_instance_id               = module.launch_template.lt_instance_id
}

module "launch_template" {
  source = "./modules/lt"

  instance_name                = "server-temp"
  name_prefix                  = "instance"
  security_group               = [module.security_group.sg-instance]
  user_data                    = base64encode(data.template_file.nginx-data-script.rendered) 
}