# Make sure to create an terraform.tfvars file to 

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}
variable "aws_key_name" {}
variable "public_key" {}
variable "aws_nat_ami" {
	default = "ami-004b0f60"
}
variable "autoscaling_ami" {
    default = "ami-31490d51"
}

variable "vpc"{
    default = {
        cidr = "10.0.0.0/16"
    }
}
variable "public_subnet" {
    default = {
        name = "vpc_public_subnet"
        cidr = "10.0.0.0/24"
        availability_zone = "us-west-1c" 
    }    
 }
variable "private_subnet" {
    default = {
        name = "vpc_private_subnet"
        cidr = "10.0.1.0/24"
        availability_zone = "us-west-1b"     
    }
} 