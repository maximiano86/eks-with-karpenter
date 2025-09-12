output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "eks_cluster" {
  value = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "instance_profile_name" {
  value = module.eks_cluster.instance_profile_name
}

output "node_role_arn" {
  value = module.eks_cluster.node_role_arn
}

output "karpenter_controller_role_arn" {
  value = module.karpenter.karpenter_controller_role_arn
}

output "sqs_queue_name" {
  description = "Name of the SQS queue used by Karpenter"
  value       = module.karpenter.sqs_queue_name
}

output "sqs_queue_url" {
  description = "URL of the SQS queue used by Karpenter"
  value       = module.karpenter.sqs_queue_url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue used by Karpenter"
  value       = module.karpenter.sqs_queue_arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for Karpenter events"
  value       = module.karpenter.sns_topic_name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for Karpenter events"
  value       = module.karpenter.sns_topic_arn
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule for Karpenter interruption events"
  value       = module.karpenter.eventbridge_rule_name
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for Karpenter interruption events"
  value       = module.karpenter.eventbridge_rule_arn
}
