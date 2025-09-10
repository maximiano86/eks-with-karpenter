variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)."
}

variable "public_subnet_cidrs" {
  type        = map(string)
  description = "List of CIDR blocks for the public subnets (e.g., [\"10.0.1.0/24\", \"10.0.2.0/24\"])."
}

variable "private_subnet_cidrs" {
  type        = map(string)
  description = "List of CIDR blocks for the private subnets (e.g., [\"10.0.101.0/24\", \"10.0.102.0/24\"])."
}

variable "prefix_name" {
  type        = string
  description = "Prefix for resources"
}

variable "eks_name" {
  type        = string
  description = "EKS cluster name"
}

variable "eks_version" {
  type        = string
  description = "Defines the EKS version"
}

variable "region" {
  type        = string
  description = "AWS working region"
  default     = "us-east-1"
}

variable "alb_controller" {
  type        = bool
  default     = false
  description = "Deploy ALB Ingress Controller or Not"
}

variable "eks_node_groups" {
  type = map(object({
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
  }))
  default = {}
}

variable "sns_subscriptions" {
  type        = list(string)
  description = "List of email to subscribe to SNS"
}

variable "karpenter_chart_version" {
  type        = string
  description = "Karpenter Helm Chart version"
}
