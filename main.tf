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
  key_name   = var.keypair_name
  public_key = "${file(var.keypair_pub_file)}"
}


// capturing all azs
data "aws_availability_zones" "azs" {
  state = "available"
}


data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  # filter {
  #   name   = "owner-alias"
  #   values = ["amazon"]
  # }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


data "template_file" "user_data" {
  template = "${file("${path.module}/scripts/user_data.tpl")}"
  vars = {
    VPN_PWD     = var.VPN_PWD
    VPN_ADDR    = var.VPN_ADDR
    VPN_DNS1    = var.VPN_DNS1
    VPN_DNS2    = var.VPN_DNS2
    VPN_CFG_DIR = var.VPN_CFG_DIR
  }
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MyVPN"
  }
}


# could use this: https://github.com/terraform-aws-modules/terraform-aws-vpc
resource "aws_instance" "my-vpn" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.my_key.id
  monitoring      = true
  security_groups = [aws_security_group.my-vpn-sg.id]
  subnet_id       = module.vpc.public_subnets[0]
  user_data = data.template_file.user_data.rendered
}
