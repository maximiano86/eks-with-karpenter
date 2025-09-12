# Install Karpenter using the locally downloaded .tgz chart file
resource "helm_release" "karpenter" {
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  version             = var.karpenter_chart_version
  chart               = "karpenter"
  namespace           = "karpenter"
  create_namespace    = true

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
      }
      rbac = {
        create = true
      }
    })
  ]
}
