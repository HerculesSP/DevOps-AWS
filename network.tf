resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public_ip

  tags = {
    Name = each.value.name
  }
}

resource "aws_db_subnet_group" "db" {
  name = "app-db-subnet-group"
  subnet_ids = [
    aws_subnet.subnets["db-1"].id,
    aws_subnet.subnets["db-2"].id
  ]

  tags = {
    Name = "app-db-subnet-group"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "ip-ngw"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnets["public-1"].id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "ngw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "public" {
  for_each = {
    for key in ["public-1", "public-2"] : key => aws_subnet.subnets[key]
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = {
    for key in ["app-1", "app-2", "web-1", "web-2", "db-1", "db-2"] : key => aws_subnet.subnets[key]
  }

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_network_acl" "app" {
  vpc_id     = aws_vpc.main.id
 subnet_ids = [
    aws_subnet.subnets["app-1"].id,
    aws_subnet.subnets["app-2"].id
  ]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.0.0/24"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    rule_no    = 105
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "app-nacl"
  }
}

resource "aws_network_acl" "web" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.subnets["web-1"].id,
    aws_subnet.subnets["web-2"].id
  ]

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.0.0/24"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 22
    to_port    = 22
  }

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    rule_no    = 105
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "web-nacl"
  }
}

resource "aws_network_acl" "db" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.subnets["db-1"].id,
    aws_subnet.subnets["db-2"].id
  ]
  
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    rule_no    = 105
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name = "db-nacl"
  }
}