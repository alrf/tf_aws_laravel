# Simple Laravel (PHP framework) based application managed by Terraform and AWS.

It uses EC2, ECS, RDS, CloudFront, S3 AWS services and was tested by Terraform v0.11.14 on us-east-2 AWS region.

Directories description:

`app` - Laravel application which uses RDS and CloudFront+S3 as content storage.

`config` - Nginx and PHP-fpm configs for building the Docker image.

`modules` - Terraform modules.

Deployed application will be available as: http://YOUR_EC2_IP and DB connection check: http://YOUR_EC2_IP/dbcheck (or CHECK DB CONNECTION link on main page).


## How to deploy

Replace `CHANGE_ME` in terraform.tfvars file to proper values.

The Docker image (`docker_image = "alrf/laravel:12345"` in terraform.tfvars) with configured Nginx, PHP and application code is already prepared and pushed, can be rebuilt by:

`docker build -t alrf/laravel:12345 -f Dockerfile . --network=host`

It doesn't contain any private data (like DB/AWS-creds, etc..) - application uses ENV-variables which are passed from terraform.tfvars as ENV-variables in ecs terraform module.

Deploying to AWS:

`terraform init`

Terraform modules for VPC don't resolve dependancies correctly, so explictly build VPC first:

`terraform apply -target=module.network`

and now:

`terraform apply`


## Extra

# Monitoring/Alerting

CloudWatch Metrics (EC2, ECS metrics are available), CloudWatch Alarms can be used.

# Security

Different Security Groups for application and RDS are used.

# Automation

All variables for deployment are mananged by terraform.tfvars. 

Further automation process can use Jenkins for building Docker images with updated application code and for building different AWS environments - scaled vertically (changing EC2 instance types) and horizontally (changing amount of instances).

# Network diagrams

Can be built by:

`terraform graph modules/network | dot -Tsvg > graph.svg`
