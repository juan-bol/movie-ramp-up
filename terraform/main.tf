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
        description = "Jenkins traffic"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [format("%s/32",local.ifconfig_co_json.ip)]
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

# resource "aws_network_interface" "rampup_network_interface" {
#     subnet_id       = data.aws_subnet.rampup_subnet.id
#     private_ips     = ["10.1.10.60"]
#     security_groups = [aws_security_group.rampup_sec_group.id]

#     tags = {
#         Name = "NetworkInterface-Terra-juan.bolanosr"
#         project = var.project_tag
#         responsible = var.responsible_tag
#     }
# }

# resource "aws_eip" "rampup_elastic_ip" {
#     vpc = true
#     network_interface = aws_network_interface.rampup_network_interface.id
#     associate_with_private_ip = "10.1.10.60"

#     depends_on = [data.aws_internet_gateway.rampup_gw, aws_instance.ec2_jenkins]

#     tags={
#         Name = "ElasticIp-Terra-juan.bolanosr"
#         project = var.project_tag
#         responsible = var.responsible_tag
#     }
# }

# resource "aws_ebs_volume" "rampup_volume" {
#     availability_zone = var.availability_zone
#     size = 8

#     tags={
#         Name = "EBS-Volume-Terra-juan.bolanosr"
#         project = var.project_tag
#         responsible = var.responsible_tag
#     }
# }

# resource "aws_volume_attachment" "rampup_vol_att" {
#     device_name = "/dev/sdh"
#     volume_id   = aws_ebs_volume.rampup_volume.id
#     instance_id = aws_instance.ec2_jenkins.id
#     force_detach = true
# }

resource "aws_instance" "ec2_jenkins" {
    ami = var.ami_linux2
    instance_type = "t2.micro"
    availability_zone = var.availability_zone
    key_name = var.key_pair
    
    # network_interface {
    #     device_index = 0
    #     network_interface_id = aws_network_interface.rampup_network_interface.id
    # }

    vpc_security_group_ids = [ aws_security_group.rampup_sec_group.id ]
    subnet_id = data.aws_subnet.rampup_subnet.id

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

# output "eip_addr" {
#   value = aws_eip.rampup_elastic_ip.public_ip
# }

output "instance_addr" {
  value = aws_instance.ec2_jenkins.public_ip
}

