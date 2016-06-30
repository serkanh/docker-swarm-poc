resource "aws_launch_configuration" "launch-config" {
    name_prefix = "launch-config"
    image_id = "${var.autoscaling_ami}"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.private.id}"]
    lifecycle {
      create_before_destroy = true
    }
    user_data = <<EOF
    #!/bin/bash 
    yum install -y aws-cli 
    yum update -y 
    #install docker v1.12.0-rc2
    curl -fsSL https://experimental.docker.com/ | sh
    wget https://test.docker.com/builds/Linux/x86_64/docker-1.12.0-rc2.tgz 
    tar xzf docker-1.12.0-rc2.tgz && sudo cp docker/* /usr/bin
    sudo service docker restart  
    sudo usermod -aG docker ec2-user
    EOF
    key_name = "${var.aws_key_name}"
}


#private dev instances security
resource "aws_security_group" "private" {
	name = "dev-private"
	description = "Allow SSH traffic from the internet within vpc"
    #port used for cluster management communications
    ingress {
        from_port = 2377
        to_port = 2377
        protocol = "-1"
        cidr_blocks = ["10.0.0.0/20"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["10.0.0.0/20"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["10.0.0.0/20"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/20"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

	vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Name = "dev-private"
    }
}


resource "aws_autoscaling_group" "dev" {
  vpc_zone_identifier = ["${aws_subnet.private_subnet.id}"]
  name = "dev-asg"
  max_size = 2
  min_size = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 2
  force_delete = true
  launch_configuration = "${aws_launch_configuration.launch-config.name}"
  tag {
    key = "Name"
    value = "dev"
    propagate_at_launch = true
  }
}
