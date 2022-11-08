
output "list_of_az" {
  value = data.aws_availability_zones.available[*].names
}




output "vpc_id" {
  value = aws_vpc.myVpc.id
}

output "db_sg" {
  value = aws_security_group.db_sg.id
}

output "web_sg" {
  value = aws_security_group.web_sg.id
}

output "app_sg" {
  value = aws_security_group.app_sg.id
}

output "bastion_sg" {
  value = aws_security_group.bastion_sg.id
}

output "lb_sg" {
  value = aws_security_group.lb_sg.id
}

output "public_subnets" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnets.*.id
}

output "private_subnets_db" {
  value = aws_subnet.db_private_subnets.*.id
}