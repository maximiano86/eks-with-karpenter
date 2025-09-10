variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster API endpoint"
}

variable "instance_profile_name" {
  type        = string
  description = "EC2 instance profile name for Karpenter nodes"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN for IRSA"
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC provider URL for IRSA"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}

variable "node_arn" {
  type        = string
  description = "Node role for Karpenter"
}

variable "region" {
  type        = string
  description = "AWS region for eks/karpenter"
  default     = "us-east-1"
}

variable "sns_subscriptions" {
  type        = list(string)
  description = "List of email to subscribe to SNS"
}

variable "karpenter_chart_version" {
  type        = string
  description = "Karpenter Helm Chart version"
}
