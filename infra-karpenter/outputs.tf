output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "eks_cluster" {
  value = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "instance_profile_name" {
  value = module.eks_cluster.instance_profile_name
}

output "node_role_arn" {
  value = module.eks_cluster.node_role_arn
}

output "oidc_provider_arn" {
  value = module.eks_cluster.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks_cluster.oidc_provider_url
}

output "karpenter_controller_role_arn" {
  value = module.karpenter.karpenter_controller_role_arn
}
