module "eks_cluster" {
  source = "./modules/eks-cluster"

  providers = {
    aws = aws
  }

  name              = var.eks_name
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.private_subnet_ids
  worker_node_cidrs = values(module.networking.private_subnet_cidrs)

  init = true

  tags = {
    Component = "EKS"
  }

  depends_on = [module.networking]
}

data "external" "oidc_thumbprint" {
  program = ["bash", "${path.module}/__scripts/fetch_thumbprint.sh"]

  query = {
    cluster_name = var.eks_name
    region       = var.region
  }

  depends_on = [module.eks_cluster]
}


module "eks_oidc_provider" {
  source = "./modules/eks-oidc"

  providers = {
    aws = aws
  }

  oidc_url        = data.external.oidc_thumbprint.result["oidc_url"]
  oidc_thumbprint = data.external.oidc_thumbprint.result["thumbprint"]
  tags = {
    Component = "EKS"
  }

  depends_on = [data.external.oidc_thumbprint]
}
