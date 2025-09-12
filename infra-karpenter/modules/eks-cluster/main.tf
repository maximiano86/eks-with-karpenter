resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn

  version = var.eks_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"
}

data "aws_ami" "eks_worker" {
  owners      = ["602401143452"] # cuenta oficial de EKS
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-al2023-x86_64-standard-1.33-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_template" "karpenter_nodes" {
  name_prefix = "${var.name}-lt-"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional" # adding optional due issue https://github.com/aws/karpenter-provider-aws/issues/8219
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      "karpenter.sh/discovery" = var.name
    }
  }
}

resource "aws_eks_node_group" "this" {
  for_each = var.eks_node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-${each.key}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  launch_template {
    id      = aws_launch_template.karpenter_nodes.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  instance_types = each.value.instance_types

  tags = merge(var.tags, {
    "karpenter.sh/discovery" = var.name
  })

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy
  ]
}
