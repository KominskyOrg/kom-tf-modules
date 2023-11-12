locals {
  cluster_config = {
    name     = var.cluster_name
    role_arn = aws_iam_role.cluster_role.arn
    version  = "1.27"
  }

  node_group_config = {
    cluster_name    = aws_eks_cluster.eks_cluster.name
    node_group_name = "${var.cluster_name}-node-group"
    node_role_arn   = aws_iam_role.node_group_role.arn
    subnet_ids      = var.subnet_ids
    scaling_config = {
      desired_size = 1
      min_size     = 1
      max_size     = 2
    }
    remote_access = {
      ec2_ssh_key               = var.pem_name
      source_security_group_ids = [var.sg_id]
    }
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = local.cluster_config.name
  role_arn = local.cluster_config.role_arn
  version  = local.cluster_config.version

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = local.node_group_config.cluster_name
  node_group_name = local.node_group_config.node_group_name
  node_role_arn   = local.node_group_config.node_role_arn
  subnet_ids      = local.node_group_config.subnet_ids

  scaling_config = local.node_group_config.scaling_config

  remote_access = local.node_group_config.remote_access

  depends_on = [aws_eks_cluster.eks_cluster]
}
