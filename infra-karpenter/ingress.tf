module "ingress" {
  source = "./modules/ingress-alb"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  cluster_name       = module.eks_cluster.cluster_name
  oidc_provider_arn  = module.eks_cluster.oidc_provider_arn
  oidc_provider_url  = module.eks_cluster.oidc_provider_url
  vpc_id             = module.networking.vpc_id
  aws_subnet_public  = module.networking.public_subnet_ids
  aws_subnet_private = module.networking.private_subnet_ids

  tags = {
    Component = "Ingress"
  }

  depends_on = [module.eks_cluster]
}

