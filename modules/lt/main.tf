resource "aws_launch_template" "instance-ng" {
  name_prefix            = "${var.name_prefix}-temp"
  image_id               = "ami-007855ac798b5175e"
  instance_type          = "t2.micro"
  key_name               = "newkey"
  vpc_security_group_ids = var.security_group
  user_data              = var.user_data
  
   tag_specifications {
    resource_type = "instance"
    tags = {
      Name : "${var.instance_name}"
    }
  }
}