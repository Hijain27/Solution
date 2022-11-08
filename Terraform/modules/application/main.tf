data "aws_ssm_parameter" "three-tier-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "applicationServer" {
  count                  = length(var.private_subnets)
  instance_type          = var.instance_type
  ami                    = data.aws_ssm_parameter.three-tier-ami.value
  vpc_security_group_ids = [var.app_sg]
  key_name               = var.key_name
  subnet_id              = var.private_subnets[count.index]
  tags                   = {
    Name  = "applicationServer  ${count.index}"
    Owner = "Himanshu Jain"
  }
}