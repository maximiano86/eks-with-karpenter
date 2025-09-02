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

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.this.arn
  description = "ARN of the OIDC provider"
}

output "oidc_provider_url" {
  value       = aws_iam_openid_connect_provider.this.url
  description = "URL of the OIDC provider"
}
