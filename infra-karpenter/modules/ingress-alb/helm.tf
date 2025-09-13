resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    yamlencode({
      clusterName = var.cluster_name
      vpcId       = var.vpc_id
      subnets = concat(
        [var.aws_subnet_public, var.aws_subnet_private]
      )
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }
      securityGroups = [
        aws_security_group.alb.id
      ]
    })
  ]
}
