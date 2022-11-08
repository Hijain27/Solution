
### Create VPC
resource "aws_vpc" "myVpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.ProjectName}-vpc"
  }
}

### INTERNET GATEWAY

resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "${var.ProjectName}-Gateway"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

#Create Public Subnet
resource "aws_subnet" "public_subnets" {
  count= length(data.aws_availability_zones.available.names)
  #count = length(var.public_subnets)
  vpc_id = aws_vpc.myVpc.id
  cidr_block = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]


  tags = {
    Name  = "public_subnets  ${count.index}"
    Owner = "Himanshu Jain"
  }
}

#Create Route Table
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "My-Route-Table-public"
  }
}

resource "aws_route" "default_public_route" {
  route_table_id         = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_internet_gateway.id
}

resource "aws_route_table_association" "public_assoc" {
  count = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.route_table_public.id
}


resource "aws_eip" "my-elastic-ip" {
  vpc = true
}

resource "aws_nat_gateway" "my_nat_gateway" {
  count = length(var.public_subnets)
  allocation_id     = aws_eip.my-elastic-ip.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)

}

#Create Private Subnet
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = var.private_subnets[count.index]
  map_public_ip_on_launch = true
  #availability_zone       = data.aws_availability_zones.availability_zones.names[0]

  tags = {
    Name  = "private_subnets  ${count.index}"
    Owner = "Himanshu Jain"
  }
}

resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "My-Route-Table-private"
  }
}

resource "aws_route" "default_private_route" {
  count = length(var.public_subnets)
  route_table_id         = aws_route_table.route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id =element(aws_nat_gateway.my_nat_gateway.*.id, count.index)
}

resource "aws_route_table_association" "private_assoc" {
  count = length(var.private_subnets)
  route_table_id = aws_route_table.route_table_private.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)

}


#Create DB Subnet
resource "aws_subnet" "db_private_subnets" {
  count = length(var.public_subnets)
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = var.db_private_subnets[count.index]
  map_public_ip_on_launch = true
  #availability_zone       = data.aws_availability_zones.availability_zones.names[0]

  tags = {

    Name  = "db_private_subnets  ${count.index}"
    Owner = "Himanshu Jain"
  }
}



#Security Group BastionHost

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH Inbound Traffic From Set IP"
  vpc_id      = aws_vpc.myVpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Allow Inbound HTTP Traffic"
  vpc_id      = aws_vpc.myVpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Security Group FrontEnd

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow SSH inbound traffic from Bastion, and HTTP inbound traffic from loadbalancer"
  vpc_id      = aws_vpc.myVpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  vpc_id      = aws_vpc.myVpc.id
  description = "Allow Inbound HTTP from FRONTEND APP, and SSH inbound traffic from Bastion"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Security Group

resource "aws_security_group" "db_sg" {
  name        = "three-tier_rds_sg"
  description = "Allow MySQL Port Inbound Traffic from Backend App Security Group"
  vpc_id      = aws_vpc.myVpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}