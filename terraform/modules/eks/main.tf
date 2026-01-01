resource "aws_eks_cluster" "this" {
  name     = "devops-eks"
  role_arn = var.cluster_role_arn
  version  = "1.31" # Kept at 1.31 for AMI compatibility

  vpc_config {
    subnet_ids = [var.public_subnet_id, var.private_subnet_id]
  }
}

# 1. FIX: Add explicit dependencies for Add-ons
resource "aws_eks_addon" "addons" {
  for_each     = toset(["vpc-cni", "coredns", "kube-proxy"])
  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.value

  # This ensures the Node Groups exist BEFORE trying to install Add-ons
  # This prevents the 'DEGRADED' timeout error you saw
  depends_on = [
    aws_eks_node_group.public,
    aws_eks_node_group.private
  ]
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# Public Node Group
resource "aws_eks_node_group" "public" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "public-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = [var.public_subnet_id]
  version         = "1.31" # Explicitly match cluster version

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  
  # Ensure cluster is fully active before nodes try to join
  depends_on = [aws_eks_cluster.this]
}

# Private Node Group (Ensure this is in your file too!)
resource "aws_eks_node_group" "private" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "private-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = [var.private_subnet_id]
  version         = "1.31" # Explicitly match cluster version

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [aws_eks_cluster.this]
}