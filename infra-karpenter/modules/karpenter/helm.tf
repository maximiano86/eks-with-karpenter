# Install Karpenter using the locally downloaded .tgz chart file
resource "helm_release" "karpenter" {
  name             = "karpenter"
  chart            = var.karpenter_helm # local .tgz
  namespace        = "karpenter"
  create_namespace = true

  values = [
    yamlencode({
      settings = {
        clusterName           = var.cluster_name
        interruptionQueueName = aws_sqs_queue.karpenter_events.name
        aws                   = { region = "us-east-1" }
      }
      serviceAccount = {
        create = true
        name   = "karpenter"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller.arn
        }
      }
      rbac = {
        create = true
      }
    })
  ]
}
