provider "aws" {
  region = var.aws_region
}

# 1. Network Module
module "vpc" {
  source = "./modules/vpc"
}

# 2. EKS Module 
module "eks" {
  source         = "./modules/eks"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.subnet_ids
}

# 3. ECR Repository 
resource "aws_ecr_repository" "app_repo" {
  name                 = "flask-app-repo"
  image_tag_mutability = "MUTABLE"
}

terraform {
  backend "s3" {
    bucket = "omer-terraform-eks"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}