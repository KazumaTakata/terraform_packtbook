# Provider configuration 
provider "aws" {
  region = "us-east-1"
}

# Resource configuration 
resource "aws_instance" "hello-instance" {
  ami           = "ami-b70554c8"
  instance_type = "t2.micro"

  tags {
    Name = "hello-instance"
  }
}
