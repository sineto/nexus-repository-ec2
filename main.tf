resource "aws_vpc" "nexus_vpc" {
  cidr_block           = var.vpc_settings.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name        = var.vpc_settings.name
    environment = "sandbox"
  }
}

resource "aws_internet_gateway" "nexus_gateway" {
  vpc_id = aws_vpc.nexus_vpc.id

  tags = {
    Name        = var.vpc_settings.gateway_name
    environment = "sandbox"
  }
}

resource "aws_subnet" "nexus_subnet" {
  cidr_block        = var.subnet_settings.cidr_block
  vpc_id            = aws_vpc.nexus_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = var.subnet_settings.name
    environment = "sandbox"
  }
}

resource "aws_route_table" "nexus_route_table" {
  vpc_id = aws_vpc.nexus_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nexus_gateway.id
  }

  tags = {
    Name        = "nexus-rt"
    environment = "sandbox"
  }
}

resource "aws_route_table_association" "nexus_rt_association" {
  subnet_id      = aws_subnet.nexus_subnet.id
  route_table_id = aws_route_table.nexus_route_table.id
}

resource "aws_security_group" "nexus_security_group" {
  name        = "nexus-sg"
  description = "Allow connection with Nexus server instance"
  vpc_id      = aws_vpc.nexus_vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP to Nexus endpoint port"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "nexus-security-group"
    environment = "sandbox"
  }
}

resource "aws_key_pair" "nexus_key_pair" {
  key_name   = var.ec2_settings.key_pair
  public_key = file(var.ec2_settings.key_pair_path)

  tags = {
    Name        = var.ec2_settings.key_pair
    environment = "sandbox"
  }
}

data "aws_ami" "linux_image" {
  most_recent = true
  owners      = var.ec2_settings.aim_owners

  filter {
    name   = "name"
    values = var.ec2_settings.aim_names
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "naxus_server" {
  ami = data.aws_ami.linux_image.id
  # name          = var.ec2_settings.name
  instance_type = var.ec2_settings.instance_type

  subnet_id              = aws_subnet.nexus_subnet.id
  key_name               = aws_key_pair.nexus_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.nexus_security_group.id]

  user_data = filebase64("./files/user_data.sh")

  tags = {
    Name        = var.ec2_settings.name
    environment = "sandbox"
  }
}

resource "aws_eip" "nexus_server_eip" {
  instance = aws_instance.naxus_server.id
  vpc      = true

  tags = {
    Name        = "${var.ec2_settings.name}-eip"
    environment = "sandbox"
  }
}
