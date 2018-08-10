provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "all" {}

resource "aws_key_pair" "auth" {
  key_name   = "test_ssh_key"
  public_key = "${file("./terraform_sshkey.pub")}"
}

resource "aws_launch_configuration" "example" {
  image_id        = "ami-b70554c8"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  key_name        = "${aws_key_pair.auth.id}"

  user_data = <<-EOF
    #!/bin/bash
    sudo yum install -y httpd
    echo “hello, I am WebServer from” $HOSTNAME >/var/www/html/index.html
    sudo systemctl start httpd
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  min_size             = 2
  max_size             = 10
  load_balancers       = ["${aws_elb.example.name}"]
  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

### Creating ELB
resource "aws_elb" "example" {
  name               = "terraform-asg-example"
  security_groups    = ["${aws_security_group.elb.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/index.html"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
}
