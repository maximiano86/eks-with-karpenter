resource "aws_security_group" "cluster" {
  name        = "${var.name}-eks-cluster-sg"
  description = "${var.name} control plane security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow worker nodes to communicate with control plane"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.worker_node_cidrs
  }

  ingress {
    description = "Allow kubelet API on worker nodes"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = var.worker_node_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "karpenter.sh/discovery" = var.name
  })
}
