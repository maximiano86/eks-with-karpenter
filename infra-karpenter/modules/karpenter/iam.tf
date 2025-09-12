# Creates the IAM role for Karpenter controller
resource "aws_iam_role" "karpenter_controller" {
  name = "${var.cluster_name}-karpenter-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = var.tags
}



# Defines the custom IAM policy granting Karpenter permissions to manage EC2, IAM, and EKS resources
resource "aws_iam_policy" "karpenter_controller" {
  name        = "${var.cluster_name}-karpenter-policy"
  description = "Custom IAM policy for Karpenter controller"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:DescribeInstanceTypes",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeImages",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DeleteTags",
          "ec2:CreateTags",
          "ssm:GetParameter",
          "pricing:GetProducts",
          "eks:DescribeCluster",
          "iam:CreateInstanceProfile",
          "iam:CreateServiceLinkedRole",
          "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = var.node_arn
      },
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster"
        ],
        Resource = "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
      }
    ]
  })
}

# Attaches the custom IAM policy to the Karpenter controller role
resource "aws_iam_role_policy_attachment" "karpenter_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = var.cluster_name
  namespace       = "karpenter"
  service_account = "karpenter"
  role_arn        = aws_iam_role.karpenter_controller.arn
}
