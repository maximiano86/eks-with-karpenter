variable "name" {
  type        = string
  description = "Name prefix for resources"
}

variable "eks_version" {
  type        = string
  description = "Defines the EKS version"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the EKS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the EKS cluster"
}

variable "worker_node_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to communicate with control plane"
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
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
