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
sns_subscriptions       = ["maximiano.alejandro@gmail.com"] #["email@something.com"]
prefix_name             = "eks"
eks_name                = "karpenter-demo"
eks_version             = "1.33"
karpenter_chart_version = "1.6.2"
alb_controller          = false # Change to true if you want to deploy ALB Ingress Controller
eks_node_groups = {
  bootstrap = {
    desired_size   = 2
    max_size       = 4
    min_size       = 2
    instance_types = ["t3.medium"]
  }
}
