variable "oidc_url" {
  description = "OIDC issuer URL from EKS cluster"
  type        = string
}

variable "oidc_thumbprint" {
  description = "SHA1 thumbprint of the OIDC provider certificate"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the OIDC provider"
  type        = map(string)
  default     = {}
}
