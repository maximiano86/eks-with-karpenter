# SQS for Karpenter
resource "aws_sqs_queue" "karpenter_events" {
  name                       = "${var.cluster_name}-karpenter-events"
  visibility_timeout_seconds = 30
}

# Allow EventBridge to publish to SQS
resource "aws_sqs_queue_policy" "karpenter_events" {
  queue_url = aws_sqs_queue.karpenter_events.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "events.amazonaws.com" },
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.karpenter_events.arn
      }
    ]
  })
}

# SNS for Notifications
resource "aws_sns_topic" "karpenter_events" {
  name = "${var.cluster_name}-karpenter-events"
}

# Email subscription 
resource "aws_sns_topic_subscription" "karpenter_email" {
  for_each  = toset(var.sns_subscriptions)
  topic_arn = aws_sns_topic.karpenter_events.arn
  protocol  = "email"
  endpoint  = each.value
}

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "karpenter_interruption" {
  name        = "${var.cluster_name}-karpenter-interruption"
  description = "Capture EC2 Spot interruption/rebalance/maintenance events"
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : [
      "AWS Health Event",
      "EC2 Spot Instance Interruption Warning",
      "EC2 Instance Rebalance Recommendation",
      "EC2 Instance State-change Notification",
      "EC2 Instance Scheduled Change"
    ]
  })
}

# Target: SQS for Karpenter
resource "aws_cloudwatch_event_target" "karpenter_to_sqs" {
  rule      = aws_cloudwatch_event_rule.karpenter_interruption.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.karpenter_events.arn
}

# Target: SNS for human notifications
resource "aws_cloudwatch_event_target" "karpenter_to_sns" {
  rule      = aws_cloudwatch_event_rule.karpenter_interruption.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.karpenter_events.arn
}

# Allow EventBridge to publish to SNS
resource "aws_sns_topic_policy" "karpenter_events" {
  arn = aws_sns_topic.karpenter_events.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "events.amazonaws.com" },
        Action    = "sns:Publish",
        Resource  = aws_sns_topic.karpenter_events.arn
      }
    ]
  })
}
