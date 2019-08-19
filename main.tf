variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "environment_name" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_instance" {}
variable "ecs_cluster" {}
variable "ecs_key_pair_name" {}
variable "max_instance_size" {}
variable "min_instance_size" {}
variable "desired_capacity" {}
variable "docker_image" {}
variable "ami_id" {}
variable "ec2_instance" {}

variable "azs" {
  type = "list"
}

variable "database_subnets" {
  type = "list"
}

variable "public_subnets" {
  type = "list"
}

variable "app_name" {}
variable "bucket_name" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

module "network" {
  source           = "./modules/network/"
  azs              = "${var.azs}"
  database_subnets = "${var.database_subnets}"
  public_subnets   = "${var.public_subnets}"
  environment_name = "${var.environment_name}"
}

module "media" {
  source           = "./modules/media/"
  app_name         = "${var.app_name}"
  environment_name = "${var.environment_name}"
  bucket_name      = "${var.bucket_name}"
}

module "database" {
  source           = "./modules/database/"
  vpc_id           = "${module.network.vpc_id}"
  db_subnet_group  = "${module.network.db_subnet_group_name}"
  environment_name = "${var.environment_name}"
  db_name          = "${var.db_name}"
  db_username      = "${var.db_username}"
  db_password      = "${var.db_password}"
  db_instance      = "${var.db_instance}"
}

module "ecs" {
  source                 = "./modules/ecs/"
  aws_access_key         = "${var.aws_access_key}"
  aws_secret_key         = "${var.aws_secret_key}"
  aws_region             = "${var.aws_region}"
  ami_id                 = "${var.ami_id}"
  bucket_name            = "${var.bucket_name}"
  cloudfront_domain_name = "${module.media.cloudfront_domain_name}"
  db_host                = "${module.database.endpoint}"
  db_name                = "${var.db_name}"
  db_username            = "${var.db_username}"
  db_password            = "${var.db_password}"
  vpc_id                 = "${module.network.vpc_id}"
  public_subnets         = "${module.network.public_subnets}"
  ecs_cluster            = "${var.ecs_cluster}"
  ecs_key_pair_name      = "${var.ecs_key_pair_name}"
  security_group         = "${module.network.default_security_group}"
  environment_name       = "${var.environment_name}"
  max_instance_size      = "${var.max_instance_size}"
  min_instance_size      = "${var.min_instance_size}"
  desired_capacity       = "${var.desired_capacity}"
  docker_image           = "${var.docker_image}"
  ec2_instance           = "${var.ec2_instance}"
}
