resource "aws_eks_cluster" "this" {
  name     = "devops-eks"
  role_arn = var.cluster_role_arn
  version  = "1.28"
  vpc_config {
    subnet_ids = [var.public_subnet_id, var.private_subnet_id]
  }
}

resource "aws_eks_addon" "addons" {
  for_each     = toset(["vpc-cni", "coredns", "kube-proxy"])
  cluster_name = aws_eks_cluster.this.name
  addon_name   = each.value
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_eks_node_group" "public" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "public-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = [var.public_subnet_id]
  scaling_config  { desired_size = 1; max_size = 1; min_size = 1 }
  instance_types  = ["t3.medium"]
}

resource "aws_eks_node_group" "private" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "private-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = [var.private_subnet_id]
  scaling_config  { desired_size = 1; max_size = 1; min_size = 1 }
  instance_types  = ["t3.medium"]
}