module "networking" {
  source = "./modules/networking"

  providers = {
    aws = aws
  }

  prefix_name = var.prefix_name
  eks_name    = var.eks_name

  vpc_cidr = "10.0.0.0/16"

  public_subnet_cidrs = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1b" = "10.0.2.0/24"
    "us-east-1c" = "10.0.3.0/24"
    "us-east-1d" = "10.0.4.0/24"
  }

  private_subnet_cidrs = {
    "us-east-1a" = "10.0.101.0/24"
    "us-east-1b" = "10.0.102.0/24"
    "us-east-1c" = "10.0.103.0/24"
    "us-east-1d" = "10.0.104.0/24"
  }

  tags = {
    Component = "Network"
  }
}
