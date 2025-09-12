# EKS + Karpenter PoC: Dynamic ARM64 Spot Node Provisioning

This repository contains a proof-of-concept EKS cluster setup using **Karpenter** to dynamically provision **ARM64 (Graviton) nodes** on **Spot Instances**, optimizing for cost and performance.

## What you'll get

### Networking and Subnets

- **VPC:** Creates an isolated private network for the infrastructure stack.
- **Internet Gateway:** Enables public subnets to access the internet.
- **Elastic IP (EIP):** Static public IP for the NAT Gateway.
- **NAT Gateway:** Allows private subnets to access the internet securely.
- **Public Subnet:** Internet-facing subnets for load balancers or public resources.
- **Private Subnet:** Internal subnets for EKS nodes or databases, without direct internet access.
- **Route Table (Public):** Routing table for public subnets with internet access.
- **Route Table (Private):** Routing table for private subnets with NAT access.
- **Route (Public Internet):** Route from public subnets to the Internet Gateway.
- **Route (Private NAT):** Route from private subnets to the NAT Gateway.
- **Route Table Association (Public):** Associates public subnets with their route table.
- **Route Table Association (Private):** Associates private subnets with their route table.

---

### EKS Cluster and Node Groups

- **IAM Role (Cluster):** IAM role for the EKS control plane.
- **IAM Policy Attachment (Cluster):** Attaches the AmazonEKSClusterPolicy to the cluster role.
- **IAM Role (Node):** IAM role for EC2 nodes managed by Karpenter.
- **IAM Instance Profile (Node):** EC2 instance profile for worker nodes.
- **IAM Policy Attachments (Node):** Grants node permissions: EKSWorkerNodePolicy, EKS_CNI_Policy, ECRReadOnly, SSM.
- **EKS Cluster:** Creates the EKS cluster with public/private access and logging enabled.
- **EKS Addon (Pod Identity):** Installs the pod identity agent for IAM roles via service accounts.
- **AMI Data Source:** Fetches the latest official EKS AMI for worker nodes.
- **Launch Template (Karpenter):** EC2 launch template for Karpenter-managed nodes.
- **EKS Node Group:** Managed node groups with autoscaling and custom launch template.
- **Security Group (Cluster):** Allows communication between nodes and control plane (ports 443, 10250).

---

### Karpenter Controller

- **IAM Role (Karpenter Controller):** IAM role for the Karpenter controller using Pod Identity.
- **IAM Policy (Karpenter Controller):** Custom policy with permissions for EC2, IAM, EKS, SQS.
- **IAM Policy Attachment:** Attaches the custom policy to the controller role.
- **Pod Identity Association:** Binds the IAM role to the Karpenter service account.
- **Helm Release (Karpenter):** Installs Karpenter via Helm with custom values.
- **EC2NodeClass:** To define launch parameters for Karpenter-managed EC2 instances, including AMI, IAM role, subnet and security group selectors.
- **NodePool:** To configure dynamic provisioning of ARM64 spot instances using the defined EC2NodeClass, with constraints on architecture, capacity type, instance category, and generation.
- **Test Deploy:** To validate ARM64 provisioning by scheduling a simple container on a Karpenter-managed node.

---

### Events and Notifications

- **SQS Queue (Karpenter Events):** Queue for EC2 interruption and rebalance events.
- **SQS Queue Policy:** Allows EventBridge to send messages to the queue.
- **SNS Topic (Karpenter Events):** Topic for human-readable notifications.
- **SNS Subscription (Email):** Email subscriptions to receive SNS alerts.
- **EventBridge Rule:** Captures EC2 spot interruption, rebalance, and maintenance events.
- **EventBridge Target (SQS):** Sends captured events to the SQS queue.
- **EventBridge Target (SNS):** Sends captured events to the SNS topic.
- **SNS Topic Policy:** Allows EventBridge to publish to the SNS topic.

---

### AWS Load Balancer Controller (ALB)

- **IAM Policy (ALB Controller):** IAM policy for the ALB controller.
- **IAM Role (ALB Controller):** IAM role for the ALB controller using Pod Identity.
- **IAM Policy Attachment:** Attaches the policy to the ALB controller role.
- **Pod Identity Association:** Binds the IAM role to the ALB controller service account.
- **Helm Release (ALB Controller):** Installs the ALB controller with VPC, subnet, and SG configuration.
- **Security Group (ALB):** Allows inbound HTTP/HTTPS traffic to the public ALB.

## Prerequisites
- AWS CLI
- Terraform
- Helm
- kubectl

## Tested Versions

This PoC was built and validated using following versions:

- **EKS:** 1.33
- **Karpenter Helm chart:** 1.6.2
- **Terraform:** v1.13.0
- **AWS CLI:** 2.28.19
- **Helm:** v3.9.0
- **kubectl:** v1.32.2

Other versions may work, but compatibility is not guaranteed.

---

## Known Issues

1. If you get this error while running `terrafrom plan/apply`:
```
│ Unable to locate chart oci://public.ecr.aws/karpenter/karpenter: unexpected status from HEAD request to
│ https://public.ecr.aws/v2/karpenter/karpenter/manifests/1.6.2: 403 Forbidden
```
Run this command and try again:
```
aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws
```

## Deployment

#### 1. Terraform Provisioning Steps
```
cd infra-karpenter
terraform init
terraform plan -var-file=values/terraform.tfvars
terraform apply -var-file=values/terraform.tfvars
```
#### 2. Deploy Karpenter Manifests
```
cd ../karpenter-manifests
AWS_ID=$(aws sts get-caller-identity --query Account --output text) # Retrieve AWS Account ID
sed "s|<aws-cloud-id>|$AWS_ID|g" ec2nodeclass.yaml > ec2nodeclass.patched.yaml # Inject AWS Account ID into ec2nodeclass.yaml
aws eks update-kubeconfig --region us-east-1 --name karpenter-demo
cat ec2nodeclass.patched.yaml # Confirm placeholder was replaced successfully
kubectl apply -f ec2nodeclass.patched.yaml
kubectl apply -f nodepool.yaml
```
Check karpenter logs:
```
kubectl -n karpenter logs deployment/karpenter -f
```
#### 3. Apply a ARM64 deployment
```
cd ../samples
kubectl apply -f deploy-arm64.yaml
kubectl get pods -w
```
The pod should schedule on an ARM64 node provisioned by Karpenter based on nodeSelector label:
```
nodeSelector:
    kubernetes.io/arch: arm64
```
### Karpenter Notes

#### EC2NodeClass:
This EC2NodeClass defines how Karpenter should launch ARM64 nodes: using the AL2023 AMI, selecting subnets and security groups by tag, and assuming a specific IAM role. It configures metadata access and sets up the base for secure, tag-driven provisioning.
```
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: ec2graviton
spec:
  amiFamily: AL2023
  amiSelectorTerms:
    - alias: "al2023@v20250821"
  role: arn:aws:iam::<aws-cloud-id>:role/karpenter-demo-eks-node-role
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: karpenter-demo
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: karpenter-demo
  metadataOptions:
    httpEndpoint: enabled
    httpTokens: optional # change to required for prod environment
```
#### NodePool:
This NodePool requirements block tells Karpenter to provision only Spot instances from modern ARM64-compatible families (m) of generation >2 ensuring cost-efficiency and performance. It's a precise filter for optimal node selection.
```
requirements:
  - key: karpenter.sh/capacity-type
    operator: In
    values: ["spot"]
  - key: karpenter.k8s.aws/instance-category
    operator: In
    values: ["m"]
  - key: karpenter.k8s.aws/instance-generation
    operator: Gt
    values: ["2"]
```
### Verification

Check nodes:
```
kubectl get nodes
```
Check pod placement:
```
kubectl get pods -o wide
```
Verify Spot instance in AWS:
```
aws ec2 describe-instances --instance-ids <instance-id> --query 'Reservations[].Instances[].InstanceLifecycle'
```
Expected Output:
```
    $ kubectl get nodes
    NAME                           STATUS     ROLES    AGE   VERSION
    ip-10-0-103-236.ec2.internal   NotReady   <none>   7s    v1.33.3-eks-3abbec1
    ip-10-0-103-30.ec2.internal    Ready      <none>   42m   v1.33.3-eks-3abbec1
    ip-10-0-104-28.ec2.internal    Ready      <none>   42m   v1.33.3-eks-3abbec1
    
    $ kubectl get nodes
    NAME                           STATUS   ROLES    AGE   VERSION
    ip-10-0-103-236.ec2.internal   Ready    <none>   69s   v1.33.3-eks-3abbec1
    ip-10-0-103-30.ec2.internal    Ready    <none>   43m   v1.33.3-eks-3abbec1
    ip-10-0-104-28.ec2.internal    Ready    <none>   43m   v1.33.3-eks-3abbec1
    
    $ kubectl get po
    NAME          READY   STATUS    RESTARTS   AGE
    hello-arm64   1/1     Running   0          2m1s
    $ kubectl logs hello-arm64
    Hello from ARM64 node
```
### Tips & Considerations

- Use AL2023 AMI for Graviton nodes.
- Use Spot instances to reduce costs.
- Ensure pods match node architecture via `nodeSelector`.
- Monitor memory/CPU limits to avoid evictions on Spot nodes.
- Consider setting `httpTokens: required` in production for enhanced metadata security.

### Cleanup
To destroy all resources created by this PoC, run:
```
terraform destroy -var-file=values/terraform.tfvars
```

### References
- [Karpenter Getting Started](https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/)
- [EKS Workshop: Karpenter](https://www.eksworkshop.com/docs/autoscaling/compute/karpenter/)
- [AWS EKS Best Practices for Karpenter](https://docs.aws.amazon.com/eks/latest/best-practices/karpenter.html)