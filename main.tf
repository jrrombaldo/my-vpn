provider "aws" {
  version = "~> 2.0"
  region  = var.region
  profile = var.aws_profile
}


resource "null_resource" "supporting-buckets" {
  # //  runs everytime
  # triggers = {
  #   build_number = timestamp()
  # }

  provisioner "local-exec" {
    working_dir = "${path.module}/"
    command     = "sh ./scripts/support-buckets.sh"

    environment = {
      BUCKET_STATE = var.bucket_state
      BUCKET_LOGS  = var.bucket_log
      REGION       = "eu-west-1"
      PROFILE      = var.aws_profile
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "my-vpn-state"
    key     = "buckets/terraform.tfstate"
    encrypt = true
    region  = "eu-west-1"
    profile = "junior"
  }
}


resource "aws_key_pair" "my_key" {
  key_name   = "my-vpn"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3h4Iy0jClTakfnVDeuCQef2a6tyUm9rqjshutGvLd6QH8KNHRZKTKinPO++nrfpZYR9g7f9OBp6JzTp63pSfGYeHt9sfEeiDg6f8RRry1i9OIv7QcoedCCMgUWg06Xx479U8kySsCcDUwFD6YaEGZfGX8+v/Ccuul///GkX6MsxRpH2/Gd7rUrtc/bNwJb8jp6m31uvfsMOiy0YeFicv5IqOBI8UhH4VIlwsH7wfcUrgitj4wjM0KsCsIta+Lv59LHPeyXIJUMyJhxcv5hgfY7V7XTsA4OMtDLSMuzRsq1+1NGaLHdJGgRghHN7DsHS9MwjAJixLnsXC9k1ff/T87 elcano-vpn-key"
}


// capturing all azs
data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners =["amazon"]
  # filter {
  #   name   = "owner-alias"
  #   values = ["amazon"]
  # }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "template_file" "init" {
  # template = "${file("init.tpl")}"
  template = "${file("scripts/user_data.sh")}"
  # vars = {
  #   consul_address = "${aws_instance.consul.private_ip}"
  # }
}



module "vpc" {
  //  source = "https://github.com/terraform-aws-modules/terraform-aws-vpc/archive/v2.17.0.zip"
  source               = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name                 = "MyVPN"
  cidr                 = var.cidr
  enable_ipv6          = false
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  azs                  = data.aws_availability_zones.azs.names
  private_subnets = [
    for az in data.aws_availability_zones.azs.names :
    cidrsubnet(var.cidr, 8, index(data.aws_availability_zones.azs.names, az))
  ]
  public_subnets = [
    for az in data.aws_availability_zones.azs.names :
    cidrsubnet(var.cidr, 8, index(data.aws_availability_zones.azs.names, az) + 10)
  ]
}



resource "aws_security_group" "my-vpn-sg" {
  name        = "my-vpn"
  description = "MyVPN Secruity Group"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MyVPN"
  }
}

# https://github.com/terraform-aws-modules/terraform-aws-vpc
resource "aws_instance" "my-vpn" {
  ami              = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.my_key.id
  monitoring      = true
  security_groups = [aws_security_group.my-vpn-sg.id]
  subnet_id       = module.vpc.public_subnets[0]
  # user_data        = ""
  # user_data_base64 = ""
}



