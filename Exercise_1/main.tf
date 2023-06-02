# TODO: Designate a cloud provider, region, and credentials
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2

variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-0380095c5425afe12", "subnet-080ad705929b5826f", "subnet-03de0b3a0d7c2ff74", "subnet-0bfbe4d819742e29e", "subnet-0ea54d38ea00f1b38", "subnet-00833e124c137a0a6"]
}

locals {
  instance_count = 4
  subnets        = slice(var.subnet_ids, 0, local.instance_count)
}

resource "aws_instance" "task_5_part1" {
  count 		= 0
  ami           = "ami-0715c1897453cabd1"
  instance_type = "t2.micro"
  subnet_id     = element(var.subnet_ids, count.index)

  tags = {
    Name = "Udacity T2-${count.index + 1}"
  }
}

# TODO: provision 2 m4.large EC2 instances named Udacity M4
#
#resource "aws_instance" "task_5_part1_B" {
#  count 		= 2
#  ami           = "ami-0715c1897453cabd1"
#  instance_type = "m4.large"
#  subnet_id     = element(var.subnet_ids, count.index + 4)
#
#  tags = {
#    Name = "Udacity M4-${count.index + 4}"
#  }
#}
