output "vpc_id" {
  description = "ID of the VPC where the EKS cluster and its resources are deployed"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs used for load balancers or public-facing components"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs used for EKS nodes and internal workloads"
  value       = module.networking.private_subnet_ids
}

output "eks_cluster" {
  description = "Name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = module.eks_cluster.cluster_endpoint
}

output "node_role_arn" {
  description = "IAM role ARN assigned to EC2 nodes (used by Karpenter or other provisioning tools)"
  value       = module.eks_cluster.node_role_arn
}

output "karpenter_controller_role_arn" {
  description = "IAM role ARN used by the Karpenter controller to manage node provisioning"
  value       = module.karpenter.karpenter_controller_role_arn
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
