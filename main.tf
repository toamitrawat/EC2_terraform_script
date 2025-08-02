terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.1.0"
}

# --- Provider Configuration ---
provider "aws" {
  region = var.aws_region
}

# --- TLS Key Pair Generation ---
resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "dev" {
  key_name   = "${var.key_name}"
  public_key = tls_private_key.dev_key.public_key_openssh
}

# --- VPC and Networking ---
resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr
  tags = {
    Name  = "dev-vpc"
    Owner = var.tag_owner
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name  = "dev-public-subnet"
    Owner = var.tag_owner
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name  = "dev-igw"
    Owner = var.tag_owner
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name  = "dev-public-rt"
    Owner = var.tag_owner
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Security Group ---
resource "aws_security_group" "dev" {
  name        = "dev-sg"
  description = "Allow SSH, HTTP, HTTPS on app ports"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App HTTPS"
    from_port   = 8443
    to_port     = 8443
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
    Name  = "dev-sg"
    Owner = var.tag_owner
  }
}

# --- Data Source for AMI ---
data "aws_ssm_parameter" "al2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.al2_ami.value]
  }
}

# --- EC2 Instance ---
resource "aws_instance" "dev" {
  ami                    = data.aws_ami.al2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.dev.id]
  key_name               = aws_key_pair.dev.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras enable corretto21
              yum install -y java-21-amazon-corretto-devel
              EOF

  tags = {
    Name  = "dev-java-app"
    Owner = var.tag_owner
  }
}
