variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
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

variable "vpc_id" {
  type        = string
  description = "VPC ID for the EKS cluster"
}

variable "aws_subnet_public" {
  type        = list(any)
  description = "Public Subnets for Internet Facing ALB's"
}

variable "aws_subnet_private" {
  type        = list(any)
  description = "Private Subnets for Internet Facing ALB's"
}
