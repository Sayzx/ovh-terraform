terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ========================================
# INFRASTRUCTURE RÉSEAU
# ========================================

# VPC isolé pour nos ressources
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-main"
  }
}

# Subnet public avec auto-assignation d'IP publique
resource "aws_subnet" "subnet" {
  vpc_id              = aws_vpc.vpc.id
  cidr_block          = "10.0.1.0/24"
  availability_zone   = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-main"
  }
}

# Internet Gateway pour l'accès public
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-main"
  }
}

# Route table pour diriger le trafic vers l'IGW
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-main"
  }
}

# Association de la route table au subnet
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# ========================================
# GROUPE DE SÉCURITÉ (Firewall)
# ========================================

# Groupe de sécurité permettant SSH et HTTP
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Accès SSH et HTTP publics"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "web-sg"
  }
}

# Ingress SSH depuis anywhere (à restreindre en prod)
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

# Ingress HTTP
resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

# Egress permettant tout le trafic sortant
resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

# ========================================
# SERVEUR VIRTUEL (EC2)
# ========================================

# Data source pour récupérer les zones de disponibilité
data "aws_availability_zones" "available" {
  state = "available"
}

# AMI Debian 12 la plus récente
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["379101102735"] # Debian

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Instance EC2 Debian 12 avec 2 vCPU et 2GB RAM
resource "aws_instance" "vm" {
  ami                    = data.aws_ami.debian.id
  instance_type          = "t3.small" # 2 vCPU, 2 GB RAM
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.ssh_key_name

  tags = {
    Name = "sayzx-vm-debian"
  }
}

# ========================================
# ADRESSE IP PUBLIQUE (Elastic IP)
# ========================================

# Association d'une Elastic IP pour accéder à la VM depuis internet
resource "aws_eip" "ip" {
  instance = aws_instance.vm.id
  domain   = "vpc"

  tags = {
    Name = "eip-main"
  }

  depends_on = [aws_internet_gateway.igw]
}

# ========================================
# OUTPUTS
# ========================================

output "instance_public_ip" {
  value       = aws_eip.ip.public_ip
  description = "IP publique de l'instance EC2"
}

output "instance_id" {
  value       = aws_instance.vm.id
  description = "ID de l'instance EC2"
}

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "ID du VPC"
}