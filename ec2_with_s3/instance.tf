provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-b70554c8"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.s3-mybucket-role-instanceprofile.name}"
}

resource "aws_key_pair" "auth" {
  key_name   = "test_ssh_key"
  public_key = "${file("./terraform_sshkey.pub")}"
}

resource "aws_security_group" "default" {
  name        = "terraform_security_group"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "b" {
  bucket = "mybucket-dfdfe"
  acl    = "private"

  tags {
    Name = "mybucket-dfdfe"
  }
}
