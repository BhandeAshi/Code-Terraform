resource "aws_db_instance" "RDS" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "MariaDB"
  engine_version       = "10.6.14"
  instance_class       = "db.t3.micro"
  identifier           = "database-1"
  username             = "admin"
  password             = "test12345"
  parameter_group_name = "default.mariadb10.6"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.security.id] 
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}
output "rds_endpoint" {
  value = aws_db_instance.RDS.endpoint
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"

  subnet_ids = [aws_subnet.subnet3.id , aws_subnet.subnet4.id , aws_subnet.subnet1.id , aws_subnet.subnet2.id]
}
resource "aws_vpc" "vpc1" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "My-vpc"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "192.168.0.0/20"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "192.168.16.0/20"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-1"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "192.168.32.0/20"
  availability_zone = "eu-west-1a"
   tags = {
    Name = "Private-2"
  }
}

resource "aws_subnet" "subnet4" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "192.168.48.0/20"
  availability_zone = "eu-west-1b"
   tags = {
    Name = "Private-3"
  }
}

resource "aws_route_table" "table1" {
  vpc_id = aws_vpc.vpc1.id
   tags = {
    Name = "PUBLIC-RT-1"
  }
}

resource "aws_route_table" "table2" {
  vpc_id = aws_vpc.vpc1.id
   tags = {
    Name = "PRIVATE-RT-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
   tags = {
    Name = "IGW"
  }
}

resource "aws_route" "route1" {
  route_table_id         = aws_route_table.table1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "association1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.table1.id
}

resource "aws_route_table_association" "association2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.table2.id
}

resource "aws_route_table_association" "association3" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.table2.id
}
resource "aws_route_table_association" "association4" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.table2.id
}


resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.elastic.id
  subnet_id     = aws_subnet.subnet1.id
   tags = {
    Name = "NAT"
  }
}

resource "aws_eip" "elastic" {}


resource "aws_route" "route2" {
  route_table_id         = aws_route_table.table2.id
  destination_cidr_block = "0.0.0.0/0"  # This is typically the default route for internet-bound traffic
  nat_gateway_id         = aws_nat_gateway.nat1.id
}