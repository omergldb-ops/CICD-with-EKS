variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ecr_name" {
  description = "Name of the ECR repository"
  default     = "flask-app-repo"
}