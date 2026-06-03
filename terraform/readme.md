
#  NextGen RoboWorld Infrastructure (Terraform)

## Overview

This repository contains Terraform Infrastructure-as-Code (IaC) for provisioning the complete AWS infrastructure required to run the NextGen RoboWorld platform on Amazon EKS.

The infrastructure is deployed in multiple stages. Each stage stores its outputs in AWS Systems Manager (SSM) Parameter Store, which are consumed by subsequent stages.

### Core AWS Services

* Amazon VPC
* Amazon EKS (v1.32)
* Amazon ECR
* Application Load Balancer (ALB)
* AWS ACM
* Route53
* IAM
* EC2 Bastion Host
* AWS Systems Manager Parameter Store

---

# Architecture Overview

```text
                                  Internet
                                      │
                                      ▼
                           Route53 Hosted Zone
                               (*.gonela.site)
                                      │
                                      ▼
                         ACM Wildcard Certificate
                                      │
                                      ▼
                    Internet Facing Application ALB
                                      │
                                      ▼
                              Amazon EKS 1.32
                                      │
              ┌───────────────────────┼───────────────────────┐
              │                       │                       │
              ▼                       ▼                       ▼

         Frontend Pod           Catalogue Pod          Payment Pod

              │
              ▼

       Backend Services

───────────────────────────────────────────────────────────────

          Amazon ECR
              │
              ▼
       Container Images

───────────────────────────────────────────────────────────────

          Bastion Host
          (RHEL9)
              │
              ▼
         kubectl Access

───────────────────────────────────────────────────────────────

      AWS Systems Manager Parameter Store

              │
              ▼

      Cross Terraform Module Communication
```

---

# Infrastructure Deployment Flow

```text
00-vpc
   │
   ▼
10-sg
   │
   ▼
20-bastion
   │
   ▼
30-ecr
   │
   ▼
40-iam
   │
   ▼
60-acm
   │
   ▼
70-ingress-alb
   │
   ▼
80-eks
```

⚠️ Deploy in this exact order.

---

# Repository Structure

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

## AWS Account

Requirements:

* AWS Account
* IAM User with AdministratorAccess
* Domain ownership of `gonela.site`
* AWS Access Key
* AWS Secret Key

---

## Install Terraform

```bash
terraform version
```

Recommended:

```text
Terraform >= 1.5
```

---

## Install AWS CLI

```bash
aws --version
```

---

## Install kubectl

```bash
kubectl version --client
```

---

## Configure AWS Credentials

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

# Networking Configuration

## VPC

```text
10.0.0.0/16
```

## Public Subnets

```text
10.0.1.0/24
10.0.2.0/24
```

## Private Subnets

```text
10.0.11.0/24
10.0.12.0/24
```

## Database Subnets

```text
10.0.21.0/24
10.0.22.0/24
```

---

# Important Design Pattern

This repository does NOT use Terraform Remote State outputs between modules.

Instead:

```text
Terraform Module
      │
      ▼
AWS Parameter Store
      │
      ▼
Next Terraform Module
```

Example:

```text
VPC
 │
 ▼
Stores vpc_id

SSM Parameter Store
 │
 ▼
Security Group Module

Security Groups
 │
 ▼
Stores SG IDs

SSM Parameter Store
 │
 ▼
EKS Module
```

This is the most important concept to understand before deployment.

---

# Step 1 — Create VPC

```bash
cd terraform/00-vpc

terraform init
terraform validate
terraform plan
terraform apply
```

Creates:

* VPC
* Public Subnets
* Private Subnets
* Database Subnets
* Internet Gateway
* Route Tables

Verify:

```bash
aws ec2 describe-vpcs
```

---

# Step 2 — Create Security Groups

```bash
cd ../10-sg

terraform init
terraform plan
terraform apply
```

Creates:

* Bastion SG
* VPN SG
* ALB SG
* EKS Control Plane SG
* EKS Node SG

Verify:

```bash
aws ec2 describe-security-groups
```

---

# Step 3 — Create Bastion Host

```bash
cd ../20-bastion

terraform init
terraform plan
terraform apply
```

Configuration:

```text
OS            : RHEL9 DevOps
Instance Type : t3.micro
Root Disk     : 50 GB GP3
```

Purpose:

* Terraform Execution
* kubectl Access
* Cluster Administration

---

# Step 4 — Create ECR Repositories

```bash
cd ../30-ecr

terraform init
terraform apply
```

Features:

* Scan On Push
* Mutable Tags
* Force Delete

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

# Step 5 — Create IAM Policy

```bash
cd ../40-iam

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

---

# Step 6 — Create ACM Certificate

```bash
cd ../60-acm

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

Verify:

```bash
aws acm list-certificates
```

---

# Step 7 — Create Ingress ALB

```bash
cd ../70-ingress-alb

terraform init
terraform apply
```

Creates:

* Internet Facing ALB
* HTTPS Listener
* DNS Records
* Target Groups

Configuration:

```text
Listener Port : 443

SSL Policy :
ELBSecurityPolicy-2016-08
```

Verify:

```bash
aws elbv2 describe-load-balancers
```

---

# Step 8 — Create EKS Cluster

```bash
cd ../80-eks

terraform init
terraform apply
```

Creates:

### Cluster

```text
Version : 1.32

Endpoint : Private
```

### Node Group

```text
Capacity Type : SPOT

Min Nodes     : 2
Desired Nodes : 2
Max Nodes     : 5
```

### Instance Types

```text
m5.large
c3.large
c4.large
c5.large
```

### Addons

```text
CoreDNS
kube-proxy
VPC CNI
Metrics Server
Pod Identity Agent
```

Verify:

```bash
aws eks list-clusters
```

---

# Configure kubectl

After EKS deployment:

```bash
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name roboshop-dev
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

# SSM Parameter Store Mapping

## VPC

```text
/roboshop/dev/vpc_id

/roboshop/dev/public_subnet_ids

/roboshop/dev/private_subnet_ids

/roboshop/dev/database_subnet_ids
```

## Security Groups

```text
/roboshop/dev/bastion_sg_id

/roboshop/dev/vpn_sg_id

/roboshop/dev/ingress_alb_sg_id

/roboshop/dev/eks_control_plane_sg_id

/roboshop/dev/eks_node_sg_id
```

## ACM

```text
/roboshop/dev/acm_certificate_arn
```

## ALB

```text
/roboshop/dev/ingress_alb_listener_arn
```

---

# Verification Checklist

```bash
aws ec2 describe-vpcs

aws ec2 describe-security-groups

aws ec2 describe-instances

aws ecr describe-repositories

aws acm list-certificates

aws elbv2 describe-load-balancers

aws eks list-clusters

kubectl get nodes

kubectl get pods -A

kubectl get svc -A
```

---

# Destroy Infrastructure

Destroy in reverse order.

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

## AWS Authentication

```bash
aws sts get-caller-identity
```

## Terraform State Issues

```bash
terraform init -reconfigure
```

## EKS Access Issues

```bash
aws eks update-kubeconfig \
--region ap-south-1 \
--name roboshop-dev
```

## ALB Not Reachable

Check:

* ACM Certificate Issued
* Route53 Record Exists
* Listener Running
* Target Group Healthy

---

# Production Recommendations

* Configure S3 Backend
* Enable DynamoDB State Locking
* Enable CloudTrail
* Enable GuardDuty
* Enable Security Hub
* Enable IRSA
* Enable Secrets Encryption
* Separate Dev/Stage/Prod Environments
* Enable EKS Logging
* Enable Backup Strategy

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

