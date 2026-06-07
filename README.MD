
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

