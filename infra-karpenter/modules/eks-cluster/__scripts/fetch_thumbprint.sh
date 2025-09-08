#!/bin/bash
set -x

# Read input from Terraform
read -r input
CLUSTER_NAME=$(echo "$input" | jq -r '.cluster_name')
REGION=$(echo "$input" | jq -r '.region')

OIDC_URL=$(aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --query "cluster.identity.oidc.issuer" \
  --output text)

OIDC_HOST=$(echo "$OIDC_URL" | awk -F/ '{print $3}')

THUMBPRINT=$(echo | openssl s_client -servername "$OIDC_HOST" -connect "$OIDC_HOST:443" 2>/dev/null \
  | openssl x509 -fingerprint -noout \
  | sed 's/^.*=//;s/://g' \
  | tr 'A-Z' 'a-z')

if [ -z "$THUMBPRINT" ]; then
  jq -n --arg error "Failed to extract thumbprint" '{error: $error}'
  exit 0
fi

jq -n --arg thumbprint "$THUMBPRINT" --arg oidc_url "$OIDC_URL" \
  '{thumbprint: $thumbprint, oidc_url: $oidc_url}'
