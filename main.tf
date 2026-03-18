locals {
  prefix = "kuankm"
}

#############################################################
#################### EC2 & EBS RESOURCES ####################
#############################################################

resource "aws_instance" "public_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  # Pulling the first public subnet from the module
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  
  # IMPORTANT: You need an existing key pair to SSH
  key_name = "kuankm-ec2-ebs-key" 

  tags = {
    Name = "${local.prefix}-ec2-ebs"
  }
}

# 1. Create the 1GB EBS Volume
resource "aws_ebs_volume" "extra_storage" {
  # The volume MUST be in the same AZ as the instance
  availability_zone = aws_instance.public_ec2.availability_zone
  size              = 1
  type              = "gp3"

  tags = {
    Name = "${local.prefix}-extra-vol"
  }
}

# 2. Attach the Volume
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.extra_storage.id
  instance_id = aws_instance.public_ec2.id
}

#############################################################
#################### NETWORKING #############################
#############################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.16.0"

  name = "${local.prefix}-vpc"
  cidr = "172.31.0.0/16"
  
  azs              = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets   = ["172.31.101.0/24", "172.31.102.0/24"]
  private_subnets  = ["172.31.1.0/24", "172.31.2.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_security_group" "allow_ssh" {
  name        = "${local.prefix}-sg-ssh"
  description = "Allow SSH inbound"
  vpc_id      = module.vpc.vpc_id # Link directly to the module VPC
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Allow all outbound (Standard practice)
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# --- Data Sources ---

data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }
  owners = ["amazon"]
}

data "aws_availability_zones" "available" {
  state = "available"
}
