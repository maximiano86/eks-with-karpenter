output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.this.arn
  description = "ARN of the OIDC provider"
}

output "oidc_provider_url" {
  value       = aws_iam_openid_connect_provider.this.url
  description = "URL of the OIDC provider"
}
