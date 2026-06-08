

# 🚀 NextGen RoboWorld Infrastructure & CI/CD Setup Guide

## Overview

This document explains how to:

* Provision AWS Infrastructure using Terraform
* Configure Amazon EKS
* Install Jenkins
* Configure Jenkins Shared Library
* Configure CI/CD Pipelines
* Automatically deploy applications to EKS

---

# Solution Architecture

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
Shared Library
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
AWS Load Balancer
    │
    ▼
Route53
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

────────────────────────────

Amazon ECR

────────────────────────────

Bastion Host

────────────────────────────

AWS Systems Manager Parameter Store
```

---

# Terraform Infrastructure Deployment

## Deployment Order

Deploy exactly in this sequence:

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

---

# Step 1 – Deploy VPC

Navigate:

```bash
cd terraform/00-vpc
```

Deploy:

```bash
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
* Route Tables
* Internet Gateway

---

## VPC Configuration

```text
VPC CIDR
10.0.0.0/16

Public Subnets
10.0.1.0/24
10.0.2.0/24

Private Subnets
10.0.11.0/24
10.0.12.0/24

Database Subnets
10.0.21.0/24
10.0.22.0/24
```

---

# Step 2 – Deploy Security Groups

```bash
cd ../10-sg

terraform init

terraform apply
```

Creates:

* Bastion SG
* VPN SG
* ALB SG
* EKS Control Plane SG
* EKS Node SG

---

# Step 3 – Deploy Bastion Host

```bash
cd ../20-bastion

terraform init

terraform apply
```

Configuration:

```text
OS:
RHEL9

Instance:
t3.micro

Disk:
50GB GP3
```

Purpose:

* kubectl access
* cluster administration
* troubleshooting

---

# Step 4 – Deploy ECR

```bash
cd ../30-ecr

terraform init

terraform apply
```

Creates repositories:

```text
frontend

catalogue

user

cart

payment

shipping
```

Features:

```text
Scan on Push

Mutable Tags

Force Delete
```

---

# Step 5 – Deploy IAM Policy

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

# Step 6 – Deploy Route53 & ACM

```bash
cd ../60-acm

terraform init

terraform apply
```

Creates:

```text
Hosted Zone:
gonela.site

Wildcard Certificate:
*.gonela.site
```

Stores:

```text
/roboshop/dev/acm_certificate_arn
```

---

# Step 7 – Deploy ALB

```bash
cd ../70-ingress-alb

terraform init

terraform apply
```

Creates:

* Internet Facing ALB
* HTTPS Listener
* Route53 Records

Configuration:

```text
Port:
443

SSL Policy:
ELBSecurityPolicy-2016-08
```

---

# Step 8 – Deploy EKS

```bash
cd ../80-eks

terraform init

terraform apply
```

Creates:

```text
Amazon EKS 1.32
```

Node Group:

```text
Name:
blue

Capacity:
SPOT

Min:
2

Desired:
2

Max:
5
```

Instance Types:

```text
m5.large

c3.large

c4.large

c5.large
```

Addons:

```text
CoreDNS

Kube Proxy

VPC CNI

Metrics Server

Pod Identity Agent
```

---

# Configure kubectl

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

# SSM Parameter Store Flow

Terraform modules communicate through SSM.

Example:

```text
VPC
 │
 ▼
Stores vpc_id

SSM Parameter Store

 │
 ▼

Security Groups

 │
 ▼

Stores SG IDs

SSM Parameter Store

 │
 ▼

EKS
```

Generated Parameters:

```text
/roboshop/dev/vpc_id

/roboshop/dev/public_subnet_ids

/roboshop/dev/private_subnet_ids

/roboshop/dev/database_subnet_ids

/roboshop/dev/bastion_sg_id

/roboshop/dev/ingress_alb_sg_id

/roboshop/dev/eks_node_sg_id

/roboshop/dev/acm_certificate_arn

/roboshop/dev/ingress_alb_listener_arn
```

---

# Jenkins Installation

Install Java:

```bash
java -version
```

Required:

```text
Java 17
```

Install Jenkins:

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import \
https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum install jenkins -y
```

Start:

```bash
sudo systemctl enable jenkins

sudo systemctl start jenkins
```

Verify:

```bash
sudo systemctl status jenkins
```

---

# Install Docker

```bash
sudo yum install docker -y

sudo systemctl enable docker

sudo systemctl start docker
```

Add Jenkins user:

```bash
sudo usermod -aG docker jenkins

sudo systemctl restart jenkins
```

---

# Configure AWS Access

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

---

# Configure EKS Access

```bash
aws eks update-kubeconfig \
--region ap-south-1 \
--name roboshop-dev
```

Verify:

```bash
kubectl get nodes
```

---

# Required Jenkins Plugins

Install:

```text
Git

Pipeline

Pipeline Stage View

Docker Pipeline

Credentials Binding

AWS Steps

Kubernetes

Blue Ocean

SSH Agent

Generic Webhook Trigger
```

---

# Jenkins Credentials

Create:

## AWS Credentials

```text
ID:
aws-creds
```

Contains:

```text
Access Key

Secret Key
```

---

## GitHub Token

```text
ID:
github-token
```

---

## ECR Credentials

```text
ID:
ecr-creds
```

---

# Configure Shared Library

Navigate:

```text
Manage Jenkins

↓

System

↓

Global Pipeline Libraries
```

Add:

```text
Name:
jenkins-shared-library
```

Repository:

```text
https://github.com/<org>/jenkins-shared-library.git
```

Branch:

```text
main
```

---

# Pipeline Mapping

| Service   | Pipeline          |
| --------- | ----------------- |
| frontend  | nodejsEKSPipeline |
| catalogue | nodejsEKSPipeline |
| user      | nodejsEKSPipeline |
| cart      | nodejsEKSPipeline |
| payment   | pythonEKSPipeline |
| shipping  | javaEKSPipeline   |

---

# NodeJS Pipeline Stages

Used By:

```text
frontend

catalogue

user

cart
```

Jenkinsfile:

```groovy
@Library('jenkins-shared-library') _

nodejsEKSPipeline()
```

Flow:

```text
Checkout Source

↓

Read package.json

↓

Install Dependencies

↓

Unit Tests

↓

Docker Build

↓

Push Image To ECR

↓

Helm Deployment

↓

Deploy To EKS
```

---

# Python Pipeline Stages

Used By:

```text
payment
```

Jenkinsfile:

```groovy
@Library('jenkins-shared-library') _

pythonEKSPipeline()
```

Flow:

```text
Checkout Source

↓

Install Requirements

↓

Testing

↓

Docker Build

↓

Push Image To ECR

↓

Helm Deployment

↓

Deploy To EKS
```

---

# Java Pipeline Stages

Used By:

```text
shipping
```

Jenkinsfile:

```groovy
@Library('jenkins-shared-library') _

javaEKSPipeline()
```

Flow:

```text
Checkout Source

↓

Read pom.xml

↓

Maven Build

↓

Unit Tests

↓

Package JAR

↓

Docker Build

↓

Push Image To ECR

↓

Helm Deployment

↓

Deploy To EKS
```

---

# Complete CI/CD Flow

```text
Developer Commit

        │

        ▼

GitHub

        │

        ▼

Webhook Trigger

        │

        ▼

Jenkins Pipeline

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

Application Running
```

---

# Verification

Verify Infrastructure:

```bash
aws eks list-clusters

aws ecr describe-repositories

aws elbv2 describe-load-balancers

aws acm list-certificates
```

Verify Kubernetes:

```bash
kubectl get nodes

kubectl get pods

kubectl get deploy

kubectl get svc

kubectl get ingress
```

Expected Services:

```text
frontend

catalogue

user

cart

shipping

payment
```

Expected Databases:

```text
mongodb

mysql

redis

rabbitmq
```

All resources should be:

```text
Running
```

---

# Final Deployment Flow

```text
Terraform Infrastructure
        │
        ▼
Amazon EKS
        │
        ▼
Jenkins
        │
        ▼
Shared Library
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
AWS ALB
        │
        ▼
Route53
        │
        ▼
Users
```

