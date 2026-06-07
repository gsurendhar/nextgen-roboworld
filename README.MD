
# 🚀 NextGen RoboWorld Platform

## Complete End-to-End Setup Guide

---

# Table of Contents

1. Executive Summary
2. Platform Overview
3. Solution Architecture
4. Infrastructure Architecture
5. Kubernetes Architecture
6. CI/CD Architecture
7. Deployment Flow
8. Technology Stack
9. Repository Structure
10. Prerequisites
11. AWS Account Setup
12. Infrastructure Deployment Overview

---

# Executive Summary

NextGen RoboWorld is a cloud-native microservices platform running on Amazon Web Services (AWS).

The platform is built using:

* Terraform (Infrastructure as Code)
* Amazon EKS (Kubernetes)
* Docker
* Amazon ECR
* Helm
* Jenkins
* Route53
* ACM
* Application Load Balancer

The application consists of multiple microservices deployed on Kubernetes and automatically delivered using Jenkins CI/CD pipelines.

The platform follows a GitOps-style workflow:

Developer → GitHub → Jenkins → Docker → ECR → Helm → EKS

---

# Platform Overview

The solution contains three major layers.

## Layer 1 - Infrastructure

Responsible for:

* VPC
* Subnets
* Security Groups
* Bastion Host
* IAM
* ECR
* ACM
* Route53
* ALB
* EKS

Provisioned using Terraform.

---

## Layer 2 - Platform

Responsible for:

* Kubernetes Cluster
* Node Groups
* Storage Classes
* Ingress
* DNS Routing

Managed by EKS and Helm.

---

## Layer 3 - Applications

Responsible for:

* Frontend
* Catalogue
* User
* Cart
* Shipping
* Payment

Deployed through Jenkins pipelines.

---

# End-to-End Architecture

```text
Developer
    │
    ▼

GitHub
    │
    ▼

Jenkins
    │
    ▼

Docker Build
    │
    ▼

Amazon ECR
    │
    ▼

Helm Deployment
    │
    ▼

Amazon EKS
    │
    ▼

Application Load Balancer
    │
    ▼

Route53 DNS
    │
    ▼

Users
```

---

# Infrastructure Architecture

```text
Internet
    │
    ▼

Route53
    │
    ▼

ACM Wildcard Certificate
    │
    ▼

Application Load Balancer
    │
    ▼

Amazon EKS

─────────────────────────────

Amazon ECR

─────────────────────────────

Bastion Host

─────────────────────────────

AWS Systems Manager Parameter Store
```

---

# Network Architecture

```text
AWS Account

└── VPC (10.0.0.0/16)

    ├── Public Subnet A
    │     ├── ALB
    │     └── Bastion
    │
    ├── Public Subnet B
    │
    ├── Private Subnet A
    │     └── EKS Worker Nodes
    │
    ├── Private Subnet B
    │     └── EKS Worker Nodes
    │
    ├── Database Subnet A
    │
    └── Database Subnet B
```

---

# Kubernetes Architecture

```text
Internet
    │
    ▼

AWS ALB
    │
    ▼

Frontend
    │
    ├── Catalogue
    │
    ├── User
    │
    ├── Cart
    │
    ├── Shipping
    │
    └── Payment

──────────────────────────

MongoDB

MySQL

Redis

RabbitMQ
```

---

# Microservice Dependency Flow

```text
Frontend
│
├── Catalogue ──► MongoDB
│
├── User ───────► MongoDB
│
├── Cart ───────► Redis
│
├── Shipping ───► MySQL
│
└── Payment ────► RabbitMQ
```

---

# CI/CD Architecture

```text
GitHub Push
      │
      ▼

Jenkins Trigger
      │
      ▼

Shared Library
      │

 ┌────┼───────────────────┐

 │    │                   │

 ▼    ▼                   ▼

NodeJS Python          Java

 │    │                   │

 ▼    ▼                   ▼

Docker Build

 │

 ▼

Amazon ECR

 │

 ▼

Helm Deployment

 │

 ▼

Amazon EKS
```

---

# Deployment Flow

The platform deployment must follow this order.

```text
Terraform Infrastructure

        │

        ▼

Configure kubectl

        │

        ▼

Install Jenkins

        │

        ▼

Configure Jenkins

        │

        ▼

Configure Shared Library

        │

        ▼

Create Jenkins Pipelines

        │

        ▼

Execute Service Pipelines

        │

        ▼

Docker Build

        │

        ▼

Push to ECR

        │

        ▼

Helm Deployment

        │

        ▼

Deploy to EKS

        │

        ▼

Application Live
```

---

# Technology Stack

## Infrastructure

* Terraform
* AWS
* EKS
* Route53
* ACM
* ALB

## CI/CD

* Jenkins
* GitHub
* Docker
* Amazon ECR

## Deployment

* Helm
* Kubernetes

## Application

### Frontend

* Nginx

### Catalogue

* NodeJS

### User

* NodeJS

### Cart

* NodeJS

### Payment

* Python

### Shipping

* Java

## Databases

* MongoDB
* Redis
* RabbitMQ
* MySQL

---

# Repository Structure

```text
nextgen-roboworld/

├── terraform/
│
├── helm/
│
├── services/
│
└── jenkins-shared-library/
```

---

# Prerequisites

Before starting ensure you have:

## AWS Account

Required:

* Administrator Access
* Access Key
* Secret Key

---

## Install Git

```bash
git --version
```

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

## Install Helm

```bash
helm version
```

---

## Install Docker

```bash
docker --version
```

---

## Install Java

```bash
java -version
```

Recommended:

```text
Java 17
```

---

## Install Maven

```bash
mvn -version
```

---

## Install NodeJS

```bash
node --version

npm --version
```

Recommended:

```text
NodeJS 20+
```

---

## Install Python

```bash
python3 --version
```

Recommended:

```text
Python 3.9+
```

---

# AWS Account Setup

Configure credentials.

```bash
aws configure
```

Provide:

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

Expected:

```json
{
  "Account": "xxxxxxxxxxxx",
  "Arn": "arn:aws:iam::xxxxxxxxxxxx:user/admin"
}
```

---

# Infrastructure Deployment Overview

Terraform modules must be deployed in the following order:

```text
00-vpc

10-sg

20-bastion

30-ecr

40-iam

60-acm

70-ingress-alb

80-eks
```



# Part 2 — Terraform Infrastructure Deployment Guide

---

# Overview

The Terraform repository provisions the complete AWS infrastructure required for the RoboWorld platform.

The infrastructure is deployed in layers.

Each layer writes outputs to AWS Systems Manager Parameter Store (SSM), and subsequent layers consume those values.

This architecture removes direct dependencies between Terraform states.

---

# Infrastructure Deployment Order

```text
00-vpc

10-sg

20-bastion

30-ecr

40-iam

60-acm

70-ingress-alb

80-eks
```

⚠️ Never change this order.

---

# Infrastructure Architecture

```text
Internet
    │
    ▼

Route53
    │
    ▼

ACM Certificate
    │
    ▼

Application Load Balancer
    │
    ▼

Amazon EKS

────────────────────────

Amazon ECR

────────────────────────

Bastion Host

────────────────────────

AWS SSM Parameter Store
```

---

# Why SSM Parameter Store?

Instead of Terraform Remote State outputs:

```text
Module A
   │
   ▼
Parameter Store
   │
   ▼
Module B
```

Example:

```text
VPC Module
    │
    ▼
Stores vpc_id

SSM Parameter Store

    │
    ▼

Security Group Module
```

---

# Network Configuration

## VPC CIDR

```text
10.0.0.0/16
```

---

## Public Subnets

```text
10.0.1.0/24

10.0.2.0/24
```

Used For:

* ALB
* Bastion Host

---

## Private Subnets

```text
10.0.11.0/24

10.0.12.0/24
```

Used For:

* EKS Worker Nodes

---

## Database Subnets

```text
10.0.21.0/24

10.0.22.0/24
```

Reserved for databases.

---

# Step 1 — Create VPC

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

---

## Resources Created

* VPC
* Public Subnets
* Private Subnets
* Database Subnets
* Route Tables
* Internet Gateway

---

## Parameters Created

```text
/roboshop/dev/vpc_id

/roboshop/dev/public_subnet_ids

/roboshop/dev/private_subnet_ids

/roboshop/dev/database_subnet_ids
```

---

## Verification

```bash
aws ec2 describe-vpcs
```

Expected:

```text
1 VPC Created
```

---

# Step 2 — Create Security Groups

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

---

## Resources Created

### Bastion SG

Used By:

```text
Bastion Host
```

---

### VPN SG

Used By:

```text
VPN Access
```

---

### ALB SG

Used By:

```text
Application Load Balancer
```

---

### EKS Control Plane SG

Used By:

```text
Amazon EKS Control Plane
```

---

### EKS Node SG

Used By:

```text
Worker Nodes
```

---

## Parameters Created

```text
/roboshop/dev/bastion_sg_id

/roboshop/dev/vpn_sg_id

/roboshop/dev/ingress_alb_sg_id

/roboshop/dev/eks_control_plane_sg_id

/roboshop/dev/eks_node_sg_id
```

---

## Verification

```bash
aws ec2 describe-security-groups
```

---

# Step 3 — Create Bastion Host

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

---

## Configuration

```text
OS:
RHEL 9 DevOps

Instance Type:
t3.micro

Storage:
50 GB GP3
```

---

## Purpose

The Bastion Host is used for:

* kubectl access
* cluster troubleshooting
* Terraform administration

---

## Verification

```bash
aws ec2 describe-instances
```

Expected:

```text
1 Running EC2 Instance
```

---

# Step 4 — Create ECR Repositories

Navigate:

```bash
cd ../30-ecr
```

Deploy:

```bash
terraform init

terraform apply
```

---

## Resources Created

Amazon ECR repositories for:

```text
frontend

catalogue

user

cart

payment

shipping
```

---

## Features Enabled

```text
Scan On Push

Mutable Tags

Force Delete
```

---

## Verification

```bash
aws ecr describe-repositories
```

Expected:

```text
6 Repositories
```

---

# Step 5 — Create IAM Policies

Navigate:

```bash
cd ../40-iam
```

Deploy:

```bash
terraform init

terraform apply
```

---

## Resources Created

```text
AWSLoadBalancerControllerIAMPolicy
```

Purpose:

Used by:

```text
AWS Load Balancer Controller
```

---

## Verification

```bash
aws iam list-policies
```

---

# Step 6 — Create Route53 & ACM

Navigate:

```bash
cd ../60-acm
```

Deploy:

```bash
terraform init

terraform apply
```

---

## Resources Created

### Route53 Hosted Zone

```text
gonela.site
```

---

### ACM Certificate

```text
*.gonela.site
```

---

### DNS Validation Records

Automatically created.

---

## Parameter Created

```text
/roboshop/dev/acm_certificate_arn
```

---

## Verification

```bash
aws acm list-certificates
```

Expected:

```text
Status = ISSUED
```

---

# Step 7 — Create Application Load Balancer

Navigate:

```bash
cd ../70-ingress-alb
```

Deploy:

```bash
terraform init

terraform apply
```

---

## Resources Created

* Internet Facing ALB
* HTTPS Listener
* Target Groups
* Route53 Records

---

## Configuration

```text
Port:
443

SSL Policy:
ELBSecurityPolicy-2016-08
```

---

## DNS

```text
*.gonela.site
```

---

## Parameter Created

```text
/roboshop/dev/ingress_alb_listener_arn
```

---

## Verification

```bash
aws elbv2 describe-load-balancers
```

Expected:

```text
1 Active ALB
```

---

# Step 8 — Create EKS Cluster

Navigate:

```bash
cd ../80-eks
```

Deploy:

```bash
terraform init

terraform apply
```

Deployment may take:

```text
15 - 25 Minutes
```

---

# EKS Configuration

## Cluster Version

```text
1.32
```

---

## Endpoint

```text
Private Only
```

---

## Node Group

```text
blue
```

---

## Capacity Type

```text
SPOT
```

---

## Node Scaling

```text
Minimum:
2

Desired:
2

Maximum:
5
```

---

## Instance Types

```text
m5.large

c3.large

c4.large

c5.large
```

---

## Addons Installed

```text
CoreDNS

Kube Proxy

VPC CNI

Metrics Server

Pod Identity Agent
```

---

## Verification

```bash
aws eks list-clusters
```

Expected:

```text
roboshop-dev
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

# Infrastructure Verification Checklist

Verify VPC:

```bash
aws ec2 describe-vpcs
```

---

Verify Security Groups:

```bash
aws ec2 describe-security-groups
```

---

Verify Bastion:

```bash
aws ec2 describe-instances
```

---

Verify ECR:

```bash
aws ecr describe-repositories
```

---

Verify ACM:

```bash
aws acm list-certificates
```

---

Verify ALB:

```bash
aws elbv2 describe-load-balancers
```

---

Verify EKS:

```bash
kubectl get nodes
```

Expected:

```text
2 Nodes Ready
```

---

# Common Issues

## Terraform Init Failure

Run:

```bash
terraform init -reconfigure
```

---

## AWS Authentication Error

Verify:

```bash
aws sts get-caller-identity
```

---

## ACM Not Issued

Check:

```text
Route53 Validation Records
```

---

## ALB Not Created

Verify:

```text
Security Groups

Subnets

ACM ARN
```

---

## EKS Node Not Joining

Check:

```bash
kubectl get nodes
```

Review:

```text
Node Group

Security Groups

IAM Roles
```

---

# Infrastructure Successfully Deployed

At this stage you have:

✅ VPC

✅ Security Groups

✅ Bastion Host

✅ ECR

✅ IAM

✅ Route53

✅ ACM

✅ ALB

✅ Amazon EKS


