packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  ansible_role = "jdk8"
  ami_name     = "ami-choshsh-${local.ansible_role}-${formatdate("YYYYMMDD", timestamp())}"
  source_ami   = "ami-0b7546e839d7ace12"
}

source "amazon-ebs" "ami" {
  ami_name      = local.ami_name
  instance_type = "t3.micro"
  region        = "ap-northeast-1"
  source_ami    = local.source_ami
  ssh_username  = "ec2-user"

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
    playbook_file = "./playbook/${local.ansible_role}.yml"
  }
}
