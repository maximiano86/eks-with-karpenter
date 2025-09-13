variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster API endpoint"
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
