variable "region" {
    description = "Region"
    default = "us-west-1"
}

variable "availability_zone" {
    description = "Availability zone"
    default = "us-west-1c"
}

variable "vpc_id" {
  description = "VPC id for ramp_up_training"
  default = "vpc-0d2831659ef89870c"
}

variable "subnet_id" {
  description = "Subnet id for ramp_up_training-public-1"
  default = "subnet-055c41fce697f9cca"
}

variable "internet_gateway_id" {
  description = "Internet gateway id for ramp_up_training-internet-gateway"
  default = "igw-0ac84600f1b39646e"
}

variable "route_table_id" {
  description = "Route table id for ramp_up_training_public"
  default = "rtb-0beec0658760f014a"
}

variable "project_tag" {
    description = "Project tag for every AWS resoruce"
    default = "ramp_up_devops"
}

variable "responsible_tag" {
    description = "Project tag for every AWS resoruce"
    default = "juan.bolanosr"
}

variable "ami_linux2" {
    description = "Amazon linux 2 AMI ID"
    default = "ami-005c06c6de69aee84"
}

variable "key_pair" {
    description = "Key pair name"
    default = "key-pair-JB"
}