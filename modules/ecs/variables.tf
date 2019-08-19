variable "bucket_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "cloudfront_domain_name" {}
variable "db_host" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "vpc_id" {}
variable "docker_image" {}
variable "ami_id" {}
variable "ec2_instance" {}

variable "public_subnets" {
  type = "list"
}

variable "ecs_cluster" {}
variable "ecs_key_pair_name" {}
variable "security_group" {}
variable "environment_name" {}
variable "max_instance_size" {}
variable "min_instance_size" {}
variable "desired_capacity" {}
