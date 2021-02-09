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
    internet_gateway_id = var.internet_gateway_id
}

data "aws_route_table" "rampup_route_table" {
    route_table_id = var.route_table_id
}

data "http" "my_public_ip" {
    url = "https://ifconfig.co/json"
    request_headers = {
        Accept = "application/json"
    }
}

locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.body)
}

output "my_ip_addr" {
  value = local.ifconfig_co_json.ip
}


resource "aws_security_group" "rampup_sec_group" {
    vpc_id = data.aws_vpc.rampup_vpc.id
    name = "SecurityGroup-Terra-juan.bolanosr"

    ingress {
        description = "Jenkins traffic from my IP"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [format("%s/32",local.ifconfig_co_json.ip)]
    }

    ingress { // curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/meta
        description = "Jenkins traffic from Github"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["192.30.252.0/22","185.199.108.0/22","140.82.112.0/20"]
    }

    ingress {
        description = "SSH traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [format("%s/32",local.ifconfig_co_json.ip)]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SecurityGroup-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }
}

data "local_file" "jenkins_user_data" {
    filename = "./provision/jenkins.sh"
}

resource "aws_instance" "ec2_jenkins" {
    ami = var.ami_linux2
    instance_type = "t2.micro"
    availability_zone = var.availability_zone
    key_name = var.key_pair

    vpc_security_group_ids = [ aws_security_group.rampup_sec_group.id ]
    subnet_id = data.aws_subnet.rampup_subnet.id

    user_data = data.local_file.jenkins_user_data.content

    volume_tags = {
        Name = "Volume-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }

    tags={
        Name = "Jenkins-EC2-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }
}

output "instance_addr" {
  value = aws_instance.ec2_jenkins.public_ip
}
