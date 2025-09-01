variable "prefix_name" {
  type        = string
  description = "Prefix for resources"
}

variable "eks_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "AWS working region"
  default     = "us-east-1"
}

variable "karpenter_helm" {
  type        = string
  description = "Karpenter file name with path"
}

variable "env" {
  type        = string
  description = "Environment can be dev, uat, prod"
}
