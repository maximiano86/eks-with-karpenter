output "karpenter_controller_role_arn" {
  description = "ARN of the Karpenter Role"
  value       = aws_iam_role.karpenter_controller.arn
}

output "sqs_queue_name" {
  description = "Name of the SQS queue used by Karpenter"
  value       = aws_sqs_queue.karpenter_events.name
}

output "sqs_queue_url" {
  description = "URL of the SQS queue used by Karpenter"
  value       = aws_sqs_queue.karpenter_events.id
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue used by Karpenter"
  value       = aws_sqs_queue.karpenter_events.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic for Karpenter events"
  value       = aws_sns_topic.karpenter_events.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for Karpenter events"
  value       = aws_sns_topic.karpenter_events.arn
}

output "eventbridge_rule_name" {
  description = "Name of the EventBridge rule for Karpenter interruption events"
  value       = aws_cloudwatch_event_rule.karpenter_interruption.name
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for Karpenter interruption events"
  value       = aws_cloudwatch_event_rule.karpenter_interruption.arn
}
