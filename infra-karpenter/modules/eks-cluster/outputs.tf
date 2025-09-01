output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.node.name
}

output "node_role_arn" {
  value = aws_iam_role.node.arn
}
