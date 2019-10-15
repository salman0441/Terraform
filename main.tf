#Creating a terraform script for installation of mongo DB instance on AWS instance

provider "aws" {
  access_key = "*****************"
  secret_key = "********************************"
  region = "us-east-2"
}

#Creating a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  }

#Creating a public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

#Creating a security group for VPC
resource "aws_security_group" "sg-vpc" {
  name = "vpc_test_web"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    //Add CIDR block of source of access
    cidr_blocks =  ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id= aws_vpc.main.id
}

#Creating a Internet Gateway for your VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Creating a new key-pair named deployer-key
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa **********************************"
}

# Creating a AWS EC2 instance
resource "aws_instance" "ubuntu"{
  ami = "ami-06d51e91cea0dac8d"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public-subnet.id
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "100"
  }
  connection {
    type = "ssh"
    user = "ubuntu"
    host = aws_instance.ubuntu.public_ip
    private_key = "./id_rsa"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y mongodb",
      "sudo systemctl status mongodb"
    ]
  }
}
