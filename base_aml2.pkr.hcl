packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ansible_role" {
  type = string
}

variable "ami_name_prefix" {
  type = string
}

variable "source_ami" {
  type = string
}

locals {
  ami_name = "${var.ami_name_prefix}-${var.ansible_role}-${formatdate("YYYYMMDD", timestamp())}"
}

source "amazon-ebs" "ami" {
  ami_name      = local.ami_name
  instance_type = "t3.micro"
  region        = "ap-northeast-1"
  source_ami    = var.source_ami
  ssh_username  = "ec2-user"

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name          = local.ami_name
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }
}

build {
  name = local.ami_name
  sources = [
    "source.amazon-ebs.ami"
  ]
  provisioner "ansible" {
    playbook_file = "./playbook/${var.ansible_role}.yml"
  }
}
