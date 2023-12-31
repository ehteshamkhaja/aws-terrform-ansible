terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

provider "aws" {
  shared_credentials_files = ["/home/devops/.aws/credentials"]
  shared_config_files = ["/home/devops/.aws/config"]
}



resource "aws_instance" "web" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  key_name      = "tf-key-pair-${random_id.server.hex}"
  availability_zone = "us-east-1c"
  depends_on = [
    aws_key_pair.tf-key-pair,
    aws_ebs_volume.example
  ]

  tags = {
    Name = "Test Server"
  }
}

resource "random_id" "server" {
  byte_length = 8
}
resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair-${random_id.server.hex}"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair-${random_id.server.hex}"
}

resource "aws_ebs_volume" "example" {
  availability_zone = "us-east-1c"
  size              = 20

  tags = {
    Name = "ec2 volume"
  }
}
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.web.id
}


