provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.region}"
}

resource "aws_vpc" "vpc" {
	cidr_block = "${var.vpc.cidr}"
	tags {
	   Name = "${var.vpc.name}"
	}
	
}

# Create Public subnet
resource "aws_subnet" "public_subnet" {
	vpc_id = "${aws_vpc.vpc.id}"
	cidr_block = "${var.public_subnet.cidr}"
	availability_zone = "${var.public_subnet.availability_zone}"
	tags {
		Name = "${var.public_subnet.name}"
	}
}

# Create Private subnet
resource "aws_subnet" "private_subnet" {
	vpc_id = "${aws_vpc.vpc.id}"
	cidr_block = "${var.private_subnet.cidr}"
	availability_zone = "${var.private_subnet.availability_zone}"
	tags {
		Name = "${var.private_subnet.name}"
	}
}

resource "aws_route_table_association" "private-subnet-assoc" {
	subnet_id = "${aws_subnet.private_subnet.id}"
	route_table_id = "${aws_route_table.private.id}"
}

# Attach IG to VPC
resource "aws_internet_gateway" "IG" {
        vpc_id = "${aws_vpc.vpc.id}"
}


# Routing table for public subnets
resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.IG.id}"
	}
}

# Associate private subnet with private routing table
resource "aws_route_table_association" "public_route_assoc" {
	subnet_id = "${aws_subnet.public_subnet.id}"
	route_table_id = "${aws_route_table.public.id}"
}

# NAT SG
resource "aws_security_group" "nat" {
	name = "nat"
	description = "Allow services from the private subnet through NAT"
	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["${aws_subnet.public_subnet.cidr_block}"]
	}
	ingress {
		from_port = 0
		to_port = 65535
		protocol = "tcp"
		cidr_blocks = ["${aws_subnet.private_subnet.cidr_block}"]
	}
    	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["199.168.151.169/32"]
	}
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["69.74.17.194/32"]
	}
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["76.108.59.202/32"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	vpc_id = "${aws_vpc.vpc.id}"
}


# Nat instance for private subnet

resource "aws_instance" "nat" {
	ami = "${var.aws_nat_ami}"
	availability_zone = "${var.public_subnet.availability_zone}"
	instance_type = "t2.micro"
	key_name = "${var.aws_key_name}"
	vpc_security_group_ids = ["${aws_security_group.nat.id}"]
	subnet_id = "${aws_subnet.public_subnet.id}"
	associate_public_ip_address = true
	source_dest_check = false
	depends_on = ["aws_subnet.public_subnet"]
	tags {
		Name = "NAT Instance"
	}
}


resource "aws_eip" "nat" {
	instance = "${aws_instance.nat.id}"
	vpc = true
	depends_on = ["aws_instance.nat"]
}

#private subnet route table 
resource "aws_route_table" "private" {
	vpc_id = "${aws_vpc.vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		instance_id = "${aws_instance.nat.id}"
	}
}


