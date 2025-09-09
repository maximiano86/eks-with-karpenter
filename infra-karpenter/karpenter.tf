module "karpenter" {
  source = "./modules/karpenter"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  cluster_name          = module.eks_cluster.cluster_name
  cluster_endpoint      = module.eks_cluster.cluster_endpoint
  instance_profile_name = module.eks_cluster.instance_profile_name
  oidc_provider_arn     = module.eks_cluster.oidc_provider_arn
  oidc_provider_url     = module.eks_cluster.oidc_provider_url
  karpenter_helm        = var.karpenter_helm

  sns_subscriptions = var.sns_subscriptions

  tags = {
    Component = "Karpenter"
  }

  node_arn = module.eks_cluster.node_role_arn

  depends_on = [module.eks_cluster]
}

