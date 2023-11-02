variable "injector_count" {
  description="Number of injectors"
  type = number
  default = 2
}
variable "ami_id" {
  description="AWS Disk image ID"
  type = string
  default = "XXXXX"
}
variable "server_size" {
  description="Size of injectors"
  type = string
  default = "t2.micro"
}
variable "subnet" {
  description="Subnet to add injectors to"
  type = string
  default = "XXXXXX"
}
variable "security_group" {
  description="Security Group"
  type = string
  default = "XXXXXX"
}
variable "iam_role" {
  description="IAM role to allow SSM SSH connection"
  type = string
  default = "XXXXXX"
}
variable "key_name" {
  description="Key name pair used for each AWS instance"
  type = string
  default = "XXXXXX"
}

provider "aws" {
  region   = "eu-west-2"
}

resource "aws_instance" "Controller" {
  ami = var.ami_id
  instance_type = var.server_size
  iam_instance_profile=var.iam_role
  subnet_id=var.subnet
  security_groups=[var.security_group]
  tags = {
    Name= "controller-performance-load-test-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  }
  user_data = <<-EOF
              echo "hello world" > /tmp/hello.txt
              EOF
}

resource "aws_instance" "Injector" {
  ami =           var.ami_id
  instance_type = var.server_size
  iam_instance_profile=var.iam_role
  subnet_id=var.subnet
  security_groups=[var.security_group]
  count =         var.injector_count
  tags = {
    Name= "injector-performance-load-test-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  }
  user_data = <<-EOF
              echo "hello world" > /tmp/hello.txt
              EOF
}
