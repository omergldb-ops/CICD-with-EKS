terraform {
  backend "s3" {
    bucket         = "omer-terraform-eks" # MUST EXIST IN AWS
    key            = "eks-pipeline/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source            = "./modules/eks"
  vpc_id            = module.vpc.vpc_id
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  cluster_role_arn  = module.iam.eks_cluster_role_arn
  node_role_arn     = module.iam.node_role_arn
}

resource "aws_ecr_repository" "app_repo" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Allows 'terraform destroy' to work even with images
}