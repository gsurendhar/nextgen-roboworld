
# NextGen RoboWorld Infrastructure Setup Guide

## Overview

This Terraform repository provisions the complete AWS infrastructure for the NextGen RoboWorld platform.

The infrastructure is deployed in multiple stages. Every stage stores information in AWS Systems Manager Parameter Store (SSM), which is later consumed by the next stage.

---

# Architecture Overview

```text
Users
  │
  ▼
Route53 DNS
  │
  ▼
ACM Wildcard Certificate (*.gonela.site)
  │
  ▼
Application Load Balancer
  │
  ▼
Amazon EKS Cluster
  │
  ├── Frontend Pods
  ├── Catalogue Pods
  ├── Cart Pods
  ├── Payment Pods
  └── Other Services
  │
  ▼
Databases

────────────────────────────────

Amazon ECR
   │
   ▼
Container Images

────────────────────────────────

Bastion Host
   │
   ▼
kubectl / Cluster Administration

────────────────────────────────

AWS SSM Parameter Store
   │
   ▼
Cross Module Communication
```

---

# Terraform Folder Structure

```text
terraform/
│
├── 00-vpc/
├── 10-sg/
├── 20-bastion/
├── 30-ecr/
├── 40-iam/
├── 60-acm/
├── 70-ingress-alb/
└── 80-eks/
```

---

# Prerequisites

Before deployment install:

## Terraform

```bash
terraform version
```

Recommended:

```text
Terraform >= 1.5
```

---

## AWS CLI

```bash
aws --version
```

---

## kubectl

```bash
kubectl version --client
```

---

## Git

```bash
git --version
```

---

# AWS Requirements

You need:

* AWS Account
* IAM User with AdministratorAccess
* Domain ownership of gonela.site
* Access Key
* Secret Key

Configure credentials:

```bash
aws configure
```

Example:

```text
AWS Access Key ID
AWS Secret Access Key
Region = ap-south-1
Output = json
```

Verify:

```bash
aws sts get-caller-identity
```

---

# Deployment Order

Deploy exactly in this sequence:

```text
1. 00-vpc
2. 10-sg
3. 20-bastion
4. 30-ecr
5. 40-iam
6. 60-acm
7. 70-ingress-alb
8. 80-eks
```

Never skip steps.

---

# STEP 1 — Create VPC

Navigate:

```bash
cd terraform/00-vpc
```

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Deploy:

```bash
terraform apply
```

Type:

```text
yes
```

Resources Created:

* VPC
* Public Subnets
* Private Subnets
* Database Subnets
* Internet Gateway
* Route Tables
* NAT Gateway (if enabled)
* VPC Peering (optional)

Verify:

```bash
aws ec2 describe-vpcs
```

---

# STEP 2 — Create Security Groups

Navigate:

```bash
cd ../10-sg
```

Deploy:

```bash
terraform init
terraform plan
terraform apply
```

Creates:

* Bastion Security Group
* VPN Security Group
* Ingress ALB Security Group
* EKS Control Plane Security Group
* EKS Node Security Group

Verify:

```bash
aws ec2 describe-security-groups
```

---

# STEP 3 — Create Bastion Host

Navigate:

```bash
cd ../20-bastion
```

Deploy:

```bash
terraform init
terraform plan
terraform apply
```

Creates:

* RHEL 9 Bastion Host
* t3.micro
* 50 GB GP3 Root Volume

Purpose:

* SSH Access
* kubectl Access
* Terraform Administration

Verify:

```bash
aws ec2 describe-instances
```

---

# STEP 4 — Create ECR Repositories

Navigate:

```bash
cd ../30-ecr
```

Deploy:

```bash
terraform init
terraform apply
```

Creates ECR repositories:

```text
project/frontend
project/catalogue
project/cart
project/payment
```

Verify:

```bash
aws ecr describe-repositories
```

Docker Login:

```bash
aws ecr get-login-password \
| docker login \
--username AWS \
--password-stdin ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com
```

---

# STEP 5 — Create IAM Policy

Navigate:

```bash
cd ../40-iam
```

Deploy:

```bash
terraform init
terraform apply
```

Creates:

```text
AWSLoadBalancerControllerIAMPolicy
```

Used by:

```text
AWS Load Balancer Controller
```

Verify:

```bash
aws iam list-policies
```

---

# STEP 6 — Create Route53 and ACM Certificate

Navigate:

```bash
cd ../60-acm
```

Deploy:

```bash
terraform init
terraform apply
```

Creates:

```text
Route53 Hosted Zone

gonela.site
```

Creates:

```text
Wildcard Certificate

*.gonela.site
```

Terraform automatically creates DNS validation records.

Verify:

```bash
aws acm list-certificates
```

---

# STEP 7 — Create Internet Facing ALB

Navigate:

```bash
cd ../70-ingress-alb
```

Deploy:

```bash
terraform init
terraform apply
```

Creates:

* Application Load Balancer
* HTTPS Listener
* Route53 Wildcard Record
* Frontend Target Group

Verify:

```bash
aws elbv2 describe-load-balancers
```

---

# STEP 8 — Create EKS Cluster

Navigate:

```bash
cd ../80-eks
```

Deploy:

```bash
terraform init
terraform apply
```

Creates:

* Amazon EKS 1.32
* Managed Node Group
* Spot Instances
* CoreDNS
* kube-proxy
* Metrics Server
* VPC CNI
* Pod Identity Agent

Configuration:

```text
Min Nodes     = 2
Desired Nodes = 2
Max Nodes     = 5
```

Verify:

```bash
aws eks list-clusters
```

---

# Configure kubectl

Update kubeconfig:

```bash
aws eks update-kubeconfig \
--region ap-south-1 \
--name <cluster-name>
```

Verify:

```bash
kubectl get nodes
```

Expected:

```text
2 Ready Nodes
```

---

# Infrastructure Verification

Check Nodes:

```bash
kubectl get nodes
```

Check Pods:

```bash
kubectl get pods -A
```

Check Services:

```bash
kubectl get svc -A
```

Check ALB:

```bash
aws elbv2 describe-load-balancers
```

Check ECR:

```bash
aws ecr describe-repositories
```

---

# Destroy Infrastructure

Destroy in reverse order:

```text
80-eks
70-ingress-alb
60-acm
40-iam
30-ecr
20-bastion
10-sg
00-vpc
```

Example:

```bash
terraform destroy
```

---

# Troubleshooting

## Terraform State Error

```bash
terraform init -reconfigure
```

## AWS Credentials Error

```bash
aws sts get-caller-identity
```

## EKS Access Error

```bash
aws eks update-kubeconfig --region ap-south-1 --name <cluster>
```

## ALB Not Reachable

Verify:

* ACM Certificate Issued
* Route53 Record Created
* ALB Listener Running

---

# Production Recommendations

* Use S3 Backend for Terraform State
* Enable DynamoDB State Locking
* Enable CloudTrail
* Enable GuardDuty
* Enable Security Hub
* Use IRSA
* Enable EKS Secrets Encryption
* Create Separate Dev/Stage/Prod Environments

---

# Final Infrastructure

```text
Route53
   │
ACM
   │
ALB
   │
EKS
   │
Applications
   │
Databases

ECR ─────► EKS

Bastion ─► EKS

SSM Parameter Store ─► All Terraform Modules
```

