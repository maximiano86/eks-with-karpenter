prefix_name    = "eks"
eks_name       = "karpenter-demo"
karpenter_helm = "./karpenter-1.6.2.tgz"
env            = "poc"
alb_controller = false # Change to true if you want to deploy ALB Ingress Controller
eks_node_groups = {
  bootstrap = {
    desired_size   = 2
    max_size       = 2
    min_size       = 1
    instance_types = ["t3.medium"]
  }
}
