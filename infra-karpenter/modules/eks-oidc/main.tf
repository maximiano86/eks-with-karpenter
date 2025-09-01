resource "aws_iam_openid_connect_provider" "this" {
  url             = var.oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [var.oidc_thumbprint]

  tags = var.tags
}
