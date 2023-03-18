resource "aws_vpc" "myvpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(var.tags, { Name = format("%s-%s-myvpc", var.appname, var.env) })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_cidr_block)
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_cidr_block[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = "true"

  tags = merge(var.tags, { Name = format("%s-%s-public-%s", var.appname, var.env, element(var.azs, count.index)) })
}

resource "aws_subnet" "private" {
  count             = length(var.private_cidr_block)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_cidr_block[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(var.tags, { Name = format("%s-%s-private-%s", var.appname, var.env, element(var.azs, count.index)) })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags   = merge(var.tags, { Name = format("%s-%s-igw", var.appname, var.env) })
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, { Name = format("%s-%s-public-rt", var.appname, var.env) })
}

resource "aws_eip" "eip" {
  vpc  = true
  tags = merge(var.tags, { Name = format("%s-%s-eip", var.appname, var.env) })
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(var.tags, { Name = format("%s-%s-nat_gateway", var.appname, var.env) })
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
  tags = merge(var.tags, { Name = format("%s-%s-private-rt", var.appname, var.env) })
}

resource "aws_route_table_association" "public-ass" {
  count          = length(var.public_cidr_block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-ass" {
  count          = length(var.private_cidr_block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_security_group" "my-sg" {
  name        = "my-sg"
  description = "my-sg inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}