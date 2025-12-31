output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name [cite: 24]
}

output "eks_cluster_endpoint" {
  description = "The API server endpoint"
  value       = module.eks.cluster_endpoint [cite: 25]
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository for Docker images"
  value       = aws_ecr_repository.app_repo.repository_url [cite: 26]
}

output "iam_role_arn" {
  description = "The ARN for the EKS node role"
  value       = module.iam.node_role_arn [cite: 27]
}