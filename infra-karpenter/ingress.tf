module "ingress" {
  count  = var.alb_controller ? 1 : 0
  source = "./modules/ingress-alb"

  providers = {
    helm = helm
  }

  cluster_name       = module.eks_cluster.cluster_name
  vpc_id             = module.networking.vpc_id
  aws_subnet_public  = module.networking.public_subnet_ids
  aws_subnet_private = module.networking.private_subnet_ids

  tags = {
    Component = "Ingress"
  }

  depends_on = [module.eks_cluster]
}

