resource "aws_eks_cluster" "my-eks" {
  name     = format("%s-%s", var.appname, var.env)
  role_arn = aws_iam_role.shubham22.arn

  vpc_config {
    subnet_ids              = var.aws_public_subnet
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = var.security_group_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.shubham22-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.shubham22-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "worker-node" {
  cluster_name    = aws_eks_cluster.my-eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.shubham222.arn
  subnet_ids      = var.aws_public_subnet
  instance_types  = var.instance_types

  remote_access {
    source_security_group_ids = var.security_group_ids
    ec2_ssh_key               = var.key_pair
  }

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.shubham22-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.shubham22-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.shubham22-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "shubham22" {
  name = "eks-cluster-shubham22"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "shubham22-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.shubham22.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "shubham22-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.shubham22.name
}

resource "aws_iam_role" "shubham222" {
  name = "eks-node-group-shubham222"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "shubham22-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.shubham222.name
}

resource "aws_iam_role_policy_attachment" "shubham22-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.shubham222.name
}

resource "aws_iam_role_policy_attachment" "shubham22-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.shubham222.name
}