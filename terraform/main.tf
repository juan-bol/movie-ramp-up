terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# AWS Provider TODO: access and secret keys must be declared as environment variables (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY)
provider "aws" {
  region = "us-west-1"
}

data "aws_vpc" "movies_vpc" {
    id = var.vpc_id
}

data "aws_subnet" "movies_subnet" {
    id = var.subnet_id
}

data "aws_internet_gateway" "movies_gw" {
    id = var.internet_gateway_id
}

data "aws_route_table" "movies_route_table" {
    id = var.route_table_id
}

resource "aws_instance" "ec2_jenkins" {
    ami = var.ami_linux2
    instance_type = "t2.micro"
    vpc_id = aws_vpc.movies_vpc
    tags={
        Name = "Jenkins EC2 Terraform"
        project : var.project_tag
        responsible : var.responsible_tag
    }
}

