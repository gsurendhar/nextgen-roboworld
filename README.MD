
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



# 2. Terraform Infrastructure Deployment Guide

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




## Jenkins Installation, Configuration, Shared Library Setup & CI/CD Pipelines

# 3.Jenkins Setup & CI/CD Configuration

---

# Overview

After Terraform infrastructure deployment, the next step is configuring Jenkins.

Jenkins is responsible for:

* Building application code
* Creating Docker images
* Pushing images to Amazon ECR
* Deploying Helm charts
* Updating applications running on Amazon EKS

The RoboWorld platform uses:

```text
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
```

---

# CI/CD Architecture

```text
Developer
    │
    ▼

GitHub Commit
    │
    ▼

Webhook Trigger
    │
    ▼

Jenkins Pipeline
    │
    ▼

Build Application
    │
    ▼

Docker Build
    │
    ▼

Push Image to ECR
    │
    ▼

Update Helm Release
    │
    ▼

Deploy to EKS
    │
    ▼

Application Running
```

---

# Jenkins Server Architecture

```text
Jenkins Server
│
├── Shared Library
│
├── Frontend Pipeline
│
├── Catalogue Pipeline
│
├── User Pipeline
│
├── Cart Pipeline
│
├── Payment Pipeline
│
└── Shipping Pipeline
```

---

# Step 1 — Install Jenkins

Jenkins can be installed on:

* EC2 Instance
* Bastion Host
* Dedicated VM

Recommended:

```text
Amazon Linux 2023

or

RHEL 9
```

---

# Install Java

Verify:

```bash
java -version
```

Required:

```text
Java 17
```

---

# Install Jenkins

```bash
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import \
https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum install jenkins -y
```

---

# Start Jenkins

```bash
sudo systemctl enable jenkins

sudo systemctl start jenkins
```

Verify:

```bash
sudo systemctl status jenkins
```

Expected:

```text
active (running)
```

---

# Open Jenkins Port

```bash
sudo firewall-cmd \
--permanent \
--add-port=8080/tcp

sudo firewall-cmd --reload
```

---

# Access Jenkins

Open:

```text
http://<jenkins-server-ip>:8080
```

---

# Retrieve Initial Password

```bash
sudo cat \
/var/lib/jenkins/secrets/initialAdminPassword
```

Copy the password.

---

# Complete Jenkins Setup Wizard

Install:

```text
Suggested Plugins
```

Create:

```text
Admin User
```

---

# Step 2 — Install Required Plugins

Navigate:

```text
Manage Jenkins

↓

Plugins
```

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

SonarQube Scanner

Configuration as Code
```

Restart Jenkins.

---

# Step 3 — Install Docker on Jenkins Server

Verify:

```bash
docker --version
```

If missing:

```bash
sudo yum install docker -y
```

Start:

```bash
sudo systemctl enable docker

sudo systemctl start docker
```

---

# Add Jenkins User to Docker Group

```bash
sudo usermod -aG docker jenkins
```

Restart:

```bash
sudo systemctl restart jenkins
```

Verify:

```bash
sudo su - jenkins

docker ps
```

No permission errors should occur.

---

# Step 4 — Install AWS CLI

Verify:

```bash
aws --version
```

---

# Configure AWS Access

```bash
aws configure
```

Provide:

```text
Access Key

Secret Key

Region
```

Verify:

```bash
aws sts get-caller-identity
```

---

# Step 5 — Install kubectl

Verify:

```bash
kubectl version --client
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

Expected:

```text
2 Ready Nodes
```

---

# Step 6 — Install Helm

Verify:

```bash
helm version
```

---

# Step 7 — Configure Jenkins Credentials

Navigate:

```text
Manage Jenkins

↓

Credentials

↓

Global
```

---

# AWS Credentials

Create:

```text
ID:
aws-creds
```

Contains:

```text
AWS Access Key

AWS Secret Key
```

---

# GitHub Credentials

Create:

```text
ID:
github-token
```

Contains:

```text
GitHub Personal Access Token
```

---

# Docker Credentials

Create:

```text
ID:
ecr-creds
```

Used for:

```text
Amazon ECR Authentication
```

---

# Sonar Credentials (Optional)

```text
ID:
sonar-token
```

---

# Step 8 — Configure GitHub Webhooks

Repository:

```text
services
```

Navigate:

```text
GitHub

↓

Settings

↓

Webhooks
```

Add:

```text
http://jenkins-server:8080/github-webhook/
```

Events:

```text
Push
```

---

# Shared Library Architecture

The project uses a Jenkins Shared Library.

Purpose:

```text
Centralized Pipeline Logic
```

Instead of:

```text
100 Lines Per Jenkinsfile
```

Every microservice contains:

```groovy
@Library('jenkins-shared-library') _
```

and calls a reusable function.

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

Default Branch:

```text
main
```

Save.

---

# Shared Library Structure

```text
jenkins-shared-library

├── vars
│
├── src
│
├── nodejsEKSPipeline.groovy
│
├── pythonEKSPipeline.groovy
│
└── javaEKSPipeline.groovy
```

---

# Service Pipeline Mapping

| Service   | Pipeline          |
| --------- | ----------------- |
| frontend  | nodejsEKSPipeline |
| catalogue | nodejsEKSPipeline |
| user      | nodejsEKSPipeline |
| cart      | nodejsEKSPipeline |
| payment   | pythonEKSPipeline |
| shipping  | javaEKSPipeline   |

---

# NodeJS Pipeline

Used By:

```text
catalogue

user

cart

frontend
```

Jenkinsfile:

```groovy
@Library('jenkins-shared-library') _

nodejsEKSPipeline()
```

---

## Pipeline Stages

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

Push to ECR

↓

Helm Deployment

↓

Deploy to EKS
```

---

# Stage 1 — Checkout

```text
GitHub
    │
    ▼
Jenkins Workspace
```

Purpose:

Download source code.

---

# Stage 2 — Read Version

Reads:

```text
package.json
```

Extracts:

```text
Application Version
```

---

# Stage 3 — Install Dependencies

```bash
npm install
```

Purpose:

Create:

```text
node_modules
```

---

# Stage 4 — Testing

Typical commands:

```bash
npm test
```

Purpose:

Validate application.

---

# Stage 5 — Docker Build

Reads:

```text
Dockerfile
```

Creates:

```text
catalogue:v1

user:v1

cart:v1

frontend:v1
```

---

# Stage 6 — Push To ECR

Logs into:

```text
Amazon ECR
```

Pushes image:

```text
catalogue:v1
```

---

# Stage 7 — Helm Deployment

Updates:

```text
imageVersion
```

inside Helm chart.

---

# Stage 8 — EKS Deployment

Executes:

```text
helm upgrade
```

Result:

```text
Rolling Deployment
```

New pods are created automatically.

---

# Python Pipeline

Used By:

```text
payment
```

Jenkinsfile:

```groovy
@Library('jenkins-shared-library') _

pythonEKSPipeline()
```

---

## Pipeline Flow

```text
Checkout

↓

Install Requirements

↓

Testing

↓

Docker Build

↓

Push ECR

↓

Helm Deploy

↓

EKS Update
```

---

# Java Pipeline

Used By:

```text
shipping
```

Jenkinsfile:

```groovy
@Library('jenkins-shared-library') _

javaEKSPipeline()
```

---

## Pipeline Flow

```text
Checkout

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

Push ECR

↓

Helm Deploy

↓

EKS Deployment
```

---

# Frontend Deployment

Frontend also follows:

```text
NodeJS Pipeline Pattern
```

Stages:

```text
Checkout

↓

Docker Build

↓

Push ECR

↓

Helm Deploy
```

---

# ECR Workflow

```text
Docker Build

      │

      ▼

Docker Image

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

# Create Jenkins Pipelines

Create:

```text
frontend

catalogue

user

cart

payment

shipping
```

Pipeline Type:

```text
Pipeline Script from SCM
```

Repository:

```text
services repository
```

Branch:

```text
main
```

Jenkinsfile:

```text
Jenkinsfile
```

---

# Verify Jenkins Setup

Run:

```text
frontend pipeline
```

Verify:

```text
SUCCESS
```

Then:

```text
catalogue

user

cart

payment

shipping
```

---

# Expected Result

After successful execution:

```text
Docker Images Created

Images Pushed to ECR

Helm Charts Updated

Pods Deployed to EKS
```

---

# Verification

Check Deployments:

```bash
kubectl get deploy
```

Check Pods:

```bash
kubectl get pods
```

Check Services:

```bash
kubectl get svc
```

At this point Jenkins CI/CD is fully operational.



## Helm Deployment Architecture, Application Flow, Service Dependencies & Verification

# 4. Application Deployment & Helm Architecture

---

# Overview

At this stage:

✅ AWS Infrastructure is deployed

✅ Amazon EKS is running

✅ Jenkins is configured

✅ Shared Library is configured

✅ CI/CD pipelines are created

The final step is understanding how applications are deployed into Kubernetes using Helm.

Important:

The RoboWorld platform does **NOT** use a single umbrella Helm chart.

Each application component has its own Helm chart and is deployed independently through Jenkins pipelines.

---

# Helm Architecture

```text id="v31x9h"
Jenkins Pipeline

        │

        ▼

Docker Build

        │

        ▼

Amazon ECR

        │

        ▼

Helm Chart

        │

        ▼

helm upgrade

        │

        ▼

Amazon EKS
```

---

# Helm Repository Structure

```text id="6tzdqk"
helm/

├── namespace.yaml

├── storageClass.yaml

├── sc.yaml

│
├── mongodb/

├── mysql/

├── redis/

├── rabbitmq/

│
├── catalogue/

├── user/

├── cart/

├── shipping/

├── payment/

└── frontend/
```

---

# Why Individual Helm Charts?

Benefits:

```text id="pl9w1z"
Independent Deployments

Independent Rollbacks

Microservice Isolation

Independent Scaling

Independent Versioning
```

Example:

```text id="mzg9yy"
Deploy Catalogue

without

Deploying User
```

---

# Kubernetes Application Architecture

```text id="ngtcl4"
Internet
    │
    ▼

AWS ALB
    │
    ▼

Frontend
    │

 ┌───┼────────────┬────────────┬──────────┐

 ▼   ▼            ▼            ▼          ▼

Catalogue       User         Cart     Shipping

 │               │            │          │

 ▼               ▼            ▼          ▼

MongoDB       MongoDB       Redis      MySQL

                     │

                     ▼

                  Payment

                     │

                     ▼

                 RabbitMQ
```

---

# Application Dependency Flow

```text id="q42mli"
Frontend

 │

 ├── Catalogue

 │      │

 │      ▼

 │   MongoDB

 │

 ├── User

 │      │

 │      ▼

 │   MongoDB

 │

 ├── Cart

 │      │

 │      ▼

 │    Redis

 │

 ├── Shipping

 │      │

 │      ▼

 │    MySQL

 │

 └── Payment

        │

        ▼

     RabbitMQ
```

---

# Deployment Order

The deployment order is extremely important.

```text id="7cbkru"
MongoDB

↓

MySQL

↓

Redis

↓

RabbitMQ

↓

Catalogue

↓

User

↓

Cart

↓

Shipping

↓

Payment

↓

Frontend
```

Reason:

Applications depend on databases and messaging systems.

---

# Database Layer

The platform contains four stateful services.

---

# MongoDB

Purpose:

```text id="4aq7mj"
Catalogue Database

User Database
```

Stores:

```text id="n97e7z"
Products

Users

Catalog Information
```

Type:

```text id="x0k1x3"
StatefulSet
```

---

# MySQL

Purpose:

```text id="d8e8y0"
Shipping Service Database
```

Stores:

```text id="ehw57n"
Shipping Data

Orders

Transactions
```

Type:

```text id="0fgw0f"
StatefulSet
```

---

# Redis

Purpose:

```text id="2j3jwe"
Cart Cache
```

Stores:

```text id="2xbz8v"
Session Data

Cart Information
```

Type:

```text id="xtzxzw"
StatefulSet
```

---

# RabbitMQ

Purpose:

```text id="n9pah5"
Message Broker
```

Used By:

```text id="edmnhs"
Payment Service
```

Type:

```text id="g1qvhs"
StatefulSet
```

---

# Backend Services

---

# Catalogue Service

Technology:

```text id="3jv6es"
NodeJS
```

Purpose:

```text id="owax2n"
Product Catalogue
```

Dependencies:

```text id="8m53u7"
MongoDB
```

Pipeline:

```text id="nznsy6"
nodejsEKSPipeline()
```

---

# User Service

Technology:

```text id="rz8spz"
NodeJS
```

Purpose:

```text id="jrx6k4"
User Management
```

Dependencies:

```text id="4t2nko"
MongoDB
```

Pipeline:

```text id="rq2hwu"
nodejsEKSPipeline()
```

---

# Cart Service

Technology:

```text id="jkncfu"
NodeJS
```

Purpose:

```text id="zxtx3y"
Shopping Cart
```

Dependencies:

```text id="hcz5ul"
Redis
```

Pipeline:

```text id="bnp1ol"
nodejsEKSPipeline()
```

---

# Shipping Service

Technology:

```text id="p8t2mb"
Java
```

Purpose:

```text id="4ffyxy"
Order Shipping
```

Dependencies:

```text id="s8hdui"
MySQL
```

Pipeline:

```text id="s9g38o"
javaEKSPipeline()
```

---

# Payment Service

Technology:

```text id="2s6rr9"
Python
```

Purpose:

```text id="t0bg42"
Payment Processing
```

Dependencies:

```text id="qpm4m3"
RabbitMQ
```

Pipeline:

```text id="69gr4w"
pythonEKSPipeline()
```

---

# Frontend Service

Technology:

```text id="9fyhvv"
Nginx
```

Purpose:

```text id="o7e1sd"
User Interface
```

Dependencies:

```text id="z37m6r"
All Backend Services
```

Pipeline:

```text id="ghp2v6"
nodejsEKSPipeline()
```

---

# Kubernetes Resources Created

Each Helm chart typically creates:

```text id="mqap0t"
Deployment

Service

ConfigMap

Horizontal Pod Autoscaler

Ingress (if applicable)
```

---

# Horizontal Pod Autoscaling

Application services support autoscaling.

Example:

```yaml id="m7g4ly"
minReplicas: 1

maxReplicas: 5

targetCPUUtilizationPercentage: 80
```

Meaning:

```text id="tn17cl"
Scale Up

when CPU > 80%
```

---

# Service Discovery

Applications communicate internally using Kubernetes Services.

Example:

```text id="2tz12w"
catalogue

user

cart

payment

shipping
```

Applications use service names rather than IP addresses.

Example:

```text id="kvj6sr"
http://catalogue

http://user

http://cart
```

---

# Jenkins Deployment Flow

For every GitHub commit:

```text id="bq35s9"
Developer Commit

        │

        ▼

GitHub

        │

        ▼

Webhook

        │

        ▼

Jenkins

        │

        ▼

Build

        │

        ▼

Docker Image

        │

        ▼

Amazon ECR

        │

        ▼

Helm Upgrade

        │

        ▼

Amazon EKS
```

---

# Rolling Deployment

When Jenkins deploys:

```text id="4h8ckk"
Old Pod

     │

     ▼

New Pod
```

Kubernetes performs rolling updates.

Benefits:

```text id="uvmqlz"
Zero Downtime

Automatic Rollback

Health Validation
```

---

# Application Verification

After all pipelines succeed:

Verify nodes:

```bash id="m5o3xw"
kubectl get nodes
```

Expected:

```text id="39wgzd"
Ready
```

---

# Verify Pods

```bash id="z8dlr6"
kubectl get pods
```

Expected:

```text id="wmtzdo"
frontend

catalogue

user

cart

payment

shipping

mongodb

mysql

redis

rabbitmq
```

Status:

```text id="5dd22v"
Running
```

---

# Verify Deployments

```bash id="rtfq5r"
kubectl get deploy
```

Expected:

```text id="s7kn17"
frontend

catalogue

user

cart

payment

shipping
```

---

# Verify Services

```bash id="d4mr6j"
kubectl get svc
```

Expected:

```text id="zjqfln"
frontend

catalogue

user

cart

payment

shipping

mongodb

mysql

redis

rabbitmq
```

---

# Verify Ingress

```bash id="35rkz3"
kubectl get ingress
```

Expected:

```text id="5tjqgs"
ALB Ingress
```

---

# Verify ALB

```bash id="j77ecv"
aws elbv2 describe-load-balancers
```

Expected:

```text id="99fq4e"
State = active
```

---

# Verify DNS

Check:

```text id="g34b1y"
https://dev.gonela.site
```

Expected:

```text id="9w05c4"
Frontend Page Loads
```

---

# End-to-End Application Flow

```text id="jjm6go"
User

 │

 ▼

Route53

 │

 ▼

AWS ALB

 │

 ▼

Frontend

 │

 ├── Catalogue

 │      │

 │      ▼

 │   MongoDB

 │

 ├── User

 │      │

 │      ▼

 │   MongoDB

 │

 ├── Cart

 │      │

 │      ▼

 │   Redis

 │

 ├── Shipping

 │      │

 │      ▼

 │   MySQL

 │

 └── Payment

        │

        ▼

     RabbitMQ
```

---

# Deployment Success Criteria

Infrastructure:

```text id="fjlwm4"
VPC

ALB

EKS

ECR

ACM

Route53
```

Status:

```text id="yhmfwj"
Healthy
```

---

Applications:

```text id="6i3wnm"
Frontend

Catalogue

User

Cart

Shipping

Payment
```

Status:

```text id="7r9kfw"
Running
```

---

Databases:

```text id="67hjlwm"
MongoDB

MySQL

Redis

RabbitMQ
```

Status:

```text id="8czm8s"
Running
```

At this point the RoboWorld platform is fully deployed and operational.

