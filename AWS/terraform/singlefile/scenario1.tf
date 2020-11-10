#################################################################
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2017, 2018.
#
#################################################################

variable "public_ssh_key_name" {
  description = "Name of the public SSH key used to connect to the virtual guest"
}

variable "size" {
  description = "Size of the VM to deploy."
  default = "small"
}

provider "aws" {
  version = "~> 3.12.0"
  region = var.aws_region	
}

module "camtags" {
  source = "../Modules/camtags"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-gov-west-1"
}

variable "aws_instance_size" {
  description = "AWS Instance Size"
  default     = "t2.medium"
}

# Amazon Machine Image (AMI) name
variable "aws_image" {
  type        = string
  description = "AMI to be used when creating EC2 instance"
}

variable "subnet_name" {
  description = "Subnet Name"
}

# Stack name (CAM instance name) to be used as EC2 instance name
variable "ibm_stack_name" {
  type = string
  default = "AWS-Single-VM"
}

resource "tls_private_key" "ansibleKey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.public_ssh_key_name
  public_key = "${tls_private_key.ansibleKey.public_key_openssh}"
}
  
resource "aws_instance" "cam_instance" {
  instance_type = var.aws_instance_size
  ami           = var.aws_image
  subnet_id     = var.subnet_name
  key_name      = aws_key_pair.generated_key.id
  tags          = "${merge(module.camtags.tagsmap, map("Name", var.ibm_stack_name))}"  
}
output "ip_address" {
  value = aws_instance.cam_instance.public_ip
}
  
output "private_key" {
   value                 = "${tls_private_key.ansibleKey.private_key_pem}"
   description           = "The private key of the main server instance."
   sensitive             = false
 }

output "size" {
  value = var.size
}
