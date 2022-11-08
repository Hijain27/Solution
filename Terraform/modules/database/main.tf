data "aws_ssm_parameter" "three-tier-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "DBServer" {
  count                  = length(var.db_private_subnets)
  instance_type          = var.instance_type
  ami                    = data.aws_ssm_parameter.three-tier-ami.value
  vpc_security_group_ids = [var.db_sg]
  key_name               = var.key_name
  subnet_id              = var.db_private_subnets[count.index]

  tags = {
    Name  = "DBServer  ${count.index}"
    Owner = "Himanshu Jain"
}
}