variable "prefix_name" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Map of AZ => CIDR for public subnets"
  type        = map(string)
}

variable "private_subnet_cidrs" {
  description = "Map of AZ => CIDR for private subnets"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "eks_name" {

}
