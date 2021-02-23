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

data "aws_subnet" "rampup_public_subnet" {
    id = var.public_subnet_id
}

data "aws_subnet" "rampup_private_subnet" {
    id = var.private_subnet_id
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


resource "aws_security_group" "rampup_sec_group_jenkins" {
    vpc_id = data.aws_vpc.rampup_vpc.id
    name = "SecurityGroup-Jenkins-Terra-juan.bolanosr"

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
        description = "SSH traffic from my IP"
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
        Name = "SecurityGroup-Jenkins-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }
}

resource "aws_security_group" "rampup_sec_group_ansible" {
    vpc_id = data.aws_vpc.rampup_vpc.id
    name = "SecurityGroup-Ansible-Terra-juan.bolanosr"

    ingress {
        description = "SSH traffic from jenkins"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [format("%s/32",aws_instance.ec2_jenkins.private_ip)]
    }

    ingress {
        description = "SSH traffic from my IP"
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
        Name = "SecurityGroup-Ansible-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }
}

resource "aws_security_group" "rampup_sec_group_hosts" {
    vpc_id = data.aws_vpc.rampup_vpc.id
    name = "SecurityGroup-Hosts-Terra-juan.bolanosr"

    ingress {
        description = "ICMP traffic from Ansible"
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = [data.aws_vpc.rampup_vpc.cidr_block]

    }

    ingress {
        description = "SSH traffic from my IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [format("%s/32",local.ifconfig_co_json.ip)]
    }

    ingress {
        description = "SSH traffic from Ansible"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [data.aws_vpc.rampup_vpc.cidr_block]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SecurityGroup-Hosts-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }
}

data "local_file" "jenkins_user_data" {
    filename = "./provision/jenkins.sh"
}

data "local_file" "ansible_user_data" {
    filename = "./provision/ansible.sh"
}

resource "aws_instance" "ec2_jenkins" {
    ami = var.ami_linux2
    instance_type = "t2.micro"
    availability_zone = var.availability_zone
    key_name = var.key_pair

    vpc_security_group_ids = [ aws_security_group.rampup_sec_group_jenkins.id ]
    subnet_id = data.aws_subnet.rampup_public_subnet.id

    user_data = data.local_file.jenkins_user_data.content

    volume_tags = {
        Name = "Volume-Jenkins-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }

    tags={
        Name = "Jenkins-EC2-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }
}

resource "aws_instance" "ec2_ansible" {
    ami = var.ami_linux2
    instance_type = "t2.micro"
    availability_zone = var.availability_zone
    key_name = var.key_pair

    vpc_security_group_ids = [ aws_security_group.rampup_sec_group_ansible.id ]
    subnet_id = data.aws_subnet.rampup_public_subnet.id

    user_data = data.local_file.ansible_user_data.content

    volume_tags = {
        Name = "Volume-Ansible-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }

    tags={
        Name = "Ansible-EC2-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }
}

resource "aws_instance" "ec2_front" {
    ami = var.ami_linux2
    instance_type = "t2.micro"
    availability_zone = var.availability_zone
    key_name = var.key_pair

    vpc_security_group_ids = [ aws_security_group.rampup_sec_group_hosts.id ]
    subnet_id = data.aws_subnet.rampup_public_subnet.id

    volume_tags = {
        Name = "Volume-Ansible-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }

    tags={
        Name = "Ansible-EC2-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }
}

resource "aws_instance" "ec2_back" {
    ami = var.ami_linux2
    instance_type = "t2.micro"
    availability_zone = var.availability_zone
    key_name = var.key_pair

    vpc_security_group_ids = [ aws_security_group.rampup_sec_group_hosts.id ]
    subnet_id = data.aws_subnet.rampup_private_subnet.id

    volume_tags = {
        Name = "Volume-Back-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }

    tags={
        Name = "Back-EC2-Terra-juan.bolanosr"
        project = var.project_tag
        responsible = var.responsible_tag
    }
}

output "jenkins_public_addr" {
  value = aws_instance.ec2_jenkins.public_ip
}

output "ansible_public_addr" {
  value = aws_instance.ec2_ansible.public_ip
}

output "front_public_addr" {
    value = aws_instance.ec2_front.public_ip
}

output "front_private_addr" {
    value = aws_instance.ec2_front.private_ip
}

output "back_private_addr" {
    value = aws_instance.ec2_back.private_ip
}