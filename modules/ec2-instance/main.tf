variable "name" {
  type        = string
  description = "nginx-server"
}

variable "ami" {
  type        = string
  description = "data.aws_ami.ubuntu.id"
    most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["099720109477"] # Canonical
}

variable "instance_type" {
  type        = string
  description = "t2.micro"
}

resource "aws_launch_template" "nginx-lt" {
  name                   = "nginx-lt"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = "newkey"
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]
  user_data              = base64encode(data.template_file.nginx_data_script.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name : "nginx-lt"
    }
  }
}


data "template_file" "nginx_data_script" {
  template = file("./user-data.tpl")
  vars = {
    server = "nginx"
  }
}

data "template_file" "apache_data_script" {
  template = file("./user-data.tpl")
  vars = {
    server = "apache2"
  }
}


# modules/ec2-instance/main.tf

variable "name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "my-instance"
}

variable "ami" {
  description = "ID of the Amazon Machine Image (AMI) to use for the instance"
  type        = string
  default     = "ami-0c94855ba95c71c99"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "user_data" {
  description = "User data to be passed to the instance"
  type        = string
  default     = ""
}

variable "subnet_id"{
  description = "ID of the subnet in which to launch the instance"
  type        = string
  default     = "subnet-0123456789abcdef"
}

variable "security_groups" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
  default     = ["sg-0123456789abcdef"]
}

resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  root_block_device {
    volume_size = 8
  }

  user_data = base64encode(var.user_data)

  tags = {
    Name = var.name
  }

  vpc_security_group_ids = var.security_groups
}
