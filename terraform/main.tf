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
  region = var.region
}

data "aws_vpc" "rampup_vpc" {
    id = var.vpc_id
}

data "aws_subnet" "rampup_subnet" {
    id = var.subnet_id
}

data "aws_internet_gateway" "rampup_gw" {
    id = var.internet_gateway_id
}

data "aws_route_table" "rampup_route_table" {
    id = var.route_table_id
}

data "http" "myip"{
    url = "https://ipv4.icanhazip.com"
}


resource "aws_security_group" "rampup_sec_group" {
    vpc_id = aws_vpc.rampup_vpc.id

    ingress {
        description = "Jenkins traffic"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [chomp(http.myip.body)/32]
    }

    ingress {
        description = "SSH traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [chomp(http.myip.body)/32]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SecurityGroup-Terra-juan.bolanosr"
        project : var.project_tag
        responsible : var.responsible_tag
    }
}

resource "aws_network_interface" "rampup_netin" {
    subnet_id       = aws_subnet.rampup_subnet.id
    private_ips     = ["10.1.10.70"]
    security_groups = [aws_security_group.rampup_sec_group.id]

    tags = {
        Name = "NetworkInterface-Terra-juan.bolanosr"
        project : var.project_tag
        responsible : var.responsible_tag
    }
}

resource "aws_eip" "rampup_elastic_ip" {
    vpc = true
    network_interface = aws_network_interface.rampup_netin.id
    associate_with_private_ip = "10.1.10.70"

    depends_on = [aws_internet_gateway.rampup_gw]
}

resource "aws_instance" "ec2_jenkins" {
    ami = var.ami_linux2
    instance_type = "t2.micro"
    availability_zone = var.region
    vpc_id = aws_vpc.rampup_vpc.id
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.rampup_netin.id
    }

    tags={
        Name = "Jenkins-EC2-Terra-juan.bolanosr"
        project : var.project_tag
        responsible : var.responsible_tag
    }
}

