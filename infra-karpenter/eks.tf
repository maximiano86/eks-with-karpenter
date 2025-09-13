module "eks_cluster" {
  source = "./modules/eks-cluster"

  providers = {
    aws = aws
  }

  name              = var.eks_name
  eks_version       = var.eks_version
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.private_subnet_ids
  worker_node_cidrs = values(module.networking.private_subnet_cidrs)

  eks_node_groups = var.eks_node_groups

  tags = {
    Component = "EKS"
  }

  depends_on = [module.networking]
}
