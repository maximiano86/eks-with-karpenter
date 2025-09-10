# EKS + Karpenter PoC: Dynamic ARM64 Spot Node Provisioning

This repository contains a proof-of-concept EKS cluster setup using **Karpenter** to dynamically provision **ARM64 (Graviton) nodes** on **Spot Instances**, optimizing for cost and performance.

## What you'll get

### Networking
- **VPC:** To create an isolated private network for our infrastructure stack.
- **Internet Gateway:** To allow public subnets to access the internet.
- **Public Subnets:** To host internet-facing resources (e.g., NAT Gateway, Load Balancers).
- **Private Subnets:** To host internal workloads like EKS nodes and Karpenter-managed instances.
- **Elastic IP:** To allocate a static public IP for the NAT Gateway.
- **NAT Gateway:** To enable private subnets to access the internet securely (e.g., for pulling container images).
- **Public Route Table:** To route traffic from public subnets to the internet. 
- **Private Route Table:** To route traffic from private subnets through the NAT Gateway.
- **ALB Security Group:** To allow inbound HTTP/HTTPS traffic and outbound access for the Application Load Balancer.
- **EKS Security Gourp:** To allow communication between worker nodes and the control plane, kubelet API access, and outbound internet traffic.

### IAM for EKS & ALB
- **Cluster IAM Role:** To allow EKS to manage control plane operations via sts:**AssumeRole.
- **Cluster IAM Policy:** To attach AmazonEKSClusterPolicy for control plane permissions.
- **Node IAM Role:** To allow EC2 instances (managed by Karpenter or Node Groups) to join the cluster.
- **Node IAM Policies:** To attach required policies for networking, registry access, and SSM:
  - AmazonEKSWorkerNodePolicy
  - AmazonEC2ContainerRegistryReadOnly
  - AmazonEKS_CNI_Policy
  - AmazonSSMManagedInstanceCore
- **Node Instance Profile:** To bind the IAM role to EC2 instances launched by Karpenter or EKS Node Groups.
- **ALB IAM Policy:** To define the permissions required by the AWS Load Balancer Controller.
- **ALB Assume Role Policy Document:** To allow the EKS OIDC provider to assume the ALB controller role.
- **ALB IAM Role:** To grant the AWS Load Balancer Controller access to AWS resources.
- **SQS Queue:** To receive EC2 spot/instance event notifications for Karpenter.
- **SQS Queue Policy:** To allow EventBridge to send messages to the SQS queue.
- **SNS Topic:** To notify humans about EC2 spot/instance events.
- **SNS Topic Subscription:** To send email notifications to subscribed users.
- **EventBridge Rule:** To capture EC2 Spot interruption, instance rebalance, and maintenance events.
- **EventBridge Target to SQS:** To route captured events to the SQS queue for Karpenter.
- **EventBridge Target to SNS:** To route captured events to the SNS topic for human notifications.
- **SNS Topic Policy:** To allow EventBridge to publish messages to the SNS topic.


### EKS, Karpenter & ALB
- **EKS Cluster:** To provision the Kubernetes control plane with logging, subnet config, and security groups.
- **EKS Init Node Group:** To bootstrap the cluster with initial capacity before Karpenter takes over.
- **Cluster Security Group:** To allow secure communication between control plane and worker nodes.
- **OIDC Provider:** To establish a trust relationship between EKS and IAM roles via OpenID Connect, enabling IRSA (IAM Roles for Service Accounts).
- **IAM Trust Policy:** To allow Karpenter’s service account to assume its IAM role via OIDC (sts:AssumeRoleWithWebIdentity).
- **Karpenter Controller Role:** To define the IAM role assumed by the Karpenter controller pod.
- **Karpenter Controller Policy:** To grant permissions for managing EC2, IAM, and EKS resources required for provisioning nodes.
- **IAM Role Attachment:** To bind the custom policy to the Karpenter controller role.
- **Helm Release (Karpenter):** To install Karpenter in the cluster using a local Helm chart, with IRSA annotations and RBAC enabled.
- **EC2NodeClass:** To define launch parameters for Karpenter-managed EC2 instances, including AMI, IAM role, subnet and security group selectors.
- **NodePool:** To configure dynamic provisioning of ARM64 spot instances using the defined EC2NodeClass, with constraints on architecture, capacity type, instance category, and generation.
- **Test Pod:** To validate ARM64 provisioning by scheduling a simple container on a Karpenter-managed node.
- **Helm Release (ALB Controller):** To deploy the AWS Load Balancer Controller into the EKS cluster using Helm.

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

## Deployment

#### 1. Terraform Provisioning Steps
```
cd infra-karpenter
helm pull oci://public.ecr.aws/karpenter/karpenter --version 1.6.2
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