provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "my_internet_gw" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags {
    Name = "my internat gateway"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my_internet_gw.id}"
  }

  tags {
    Name = "main"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.r.id}"
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.my_vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.my_vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
}

module "crazy_foods" {
  source    = "./modules/application"
  vpc_id    = "${aws_vpc.my_vpc.id}"
  subnet_id = "${aws_subnet.public.id}"
  name      = "CrazyFoods"
}

module "mighty_trousers" {
  source    = "./modules/application"
  vpc_id    = "${aws_vpc.my_vpc.id}"
  subnet_id = "${aws_subnet.private.id}"
  name      = "MightyTrousers"
}
