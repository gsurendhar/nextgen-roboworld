

# 🚀 NextGen RoboWorld Services

## Overview

NextGen RoboWorld is a cloud-native microservices application deployed on Amazon EKS.

The services are:

| Service   | Technology       | Database |
| --------- | ---------------- | -------- |
| Frontend  | Nginx            | None     |
| Catalogue | NodeJS           | MongoDB  |
| User      | NodeJS           | MongoDB  |
| Cart      | NodeJS           | Redis    |
| Shipping  | Java Spring Boot | MySQL    |
| Payment   | Python           | RabbitMQ |

The application is containerized using Docker, stored in Amazon ECR, and deployed to Amazon EKS using Helm charts through Jenkins CI/CD pipelines.

---

# High-Level Architecture

```text
                              Internet
                                  │
                                  ▼
                         AWS Load Balancer
                                  │
                                  ▼
                              Frontend
                                  │
        ┌──────────────┬──────────────┬──────────────┐
        ▼              ▼              ▼              ▼

   Catalogue         User          Cart         Shipping
        │              │              │              │
        ▼              ▼              ▼              ▼

    MongoDB        MongoDB         Redis         MySQL

                        │
                        ▼

                     Payment
                        │
                        ▼

                    RabbitMQ
```

---

# CI/CD Architecture

```text
Developer
    │
    ▼
GitHub
    │
    ▼
Jenkins
    │
 ┌──┼───────────────┐
 │  │               │
 ▼  ▼               ▼

NodeJS        Python        Java

 │              │            │

 ▼              ▼            ▼

Docker Build Docker Build Docker Build

 │              │            │

 ▼              ▼            ▼

Amazon ECR

 │

 ▼

Helm Deployment

 │

 ▼

Amazon EKS
```

---

# Repository Structure

```text
services/
│
├── frontend/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── nginx.conf
│
├── catalogue/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── server.js
│
├── user/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── server.js
│
├── cart/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── server.js
│
├── payment/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   ├── payment.py
│   └── requirements.txt
│
└── shipping/
    ├── Dockerfile
    ├── Jenkinsfile
    ├── pom.xml
    └── src/
```

---

# Service Dependency Flow

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

# Prerequisites

Install:

```bash
Git
Docker
AWS CLI
kubectl
Helm
Jenkins
```

Technology Requirements:

```text
NodeJS 20+
Python 3.9+
Java 17+
Maven 3.9+
Docker 24+
```

Verify:

```bash
docker --version
node --version
python3 --version
java -version
mvn -version
```

---

# Local Development Setup

Clone:

```bash
git clone <repository-url>

cd services
```

---

# Service Setup

## Catalogue Service

Install:

```bash
cd catalogue

npm install
```

Environment Variables:

```bash
MONGO=true

MONGO_URL=mongodb://mongodb:27017/catalogue
```

Run:

```bash
node server.js
```

---

## User Service

Environment Variables:

```bash
MONGO=true

MONGO_URL=mongodb://mongodb:27017/users

REDIS_URL=redis://redis:6379
```

Run:

```bash
npm install

node server.js
```

---

## Cart Service

Environment Variables:

```bash
REDIS_HOST=redis

CATALOGUE_HOST=catalogue
```

Run:

```bash
npm install

node server.js
```

---

## Payment Service

Install:

```bash
pip install -r requirements.txt
```

Environment Variables:

```bash
AMQP_HOST=rabbitmq

AMQP_USER=roboshop

AMQP_PASS=roboshop123
```

Run:

```bash
python payment.py
```

---

## Shipping Service

Build:

```bash
mvn clean package
```

Run:

```bash
java -jar target/shipping.jar
```

---

# Docker Build Process

Each microservice contains its own Dockerfile.

Example:

```bash
docker build -t catalogue:v1 .
```

Run:

```bash
docker run -d -p 8080:8080 catalogue:v1
```

Repeat for:

```text
catalogue
user
cart
payment
shipping
frontend
```

---

# Jenkins Setup

## Install Jenkins

```bash
docker run -d \
--name jenkins \
-p 8080:8080 \
-p 50000:50000 \
jenkins/jenkins:lts
```

Access:

```text
http://localhost:8080
```

Get initial password:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

# Required Jenkins Plugins

Install:

```text
Git
Pipeline
Docker Pipeline
Credentials Binding
AWS Steps
Kubernetes
Blue Ocean
```

---

# Jenkins Credentials

Configure:

```text
AWS Credentials

GitHub Token

ECR Credentials
```

---

# Jenkins Shared Library

Every service uses a shared library.

Example:

```groovy
@Library('jenkins-shared-library') _

nodejsEKSPipeline()
```

Purpose:

* Standardized builds
* Reusable pipeline logic
* Reduced duplication

---

# Jenkins Pipelines Explained

## NodeJS Services

Used By:

```text
catalogue
user
cart
```

Pipeline:

```groovy
nodejsEKSPipeline()
```

Stages:

```text
1. Checkout Source

2. npm install

3. Code Validation

4. Docker Build

5. ECR Login

6. Push Image

7. Helm Update

8. EKS Deployment
```

---

## Python Service

Used By:

```text
payment
```

Pipeline:

```groovy
pythonEKSPipeline()
```

Stages:

```text
1. Checkout

2. pip install

3. Security Scan

4. Docker Build

5. Push to ECR

6. Helm Deployment
```

---

## Java Service

Used By:

```text
shipping
```

Pipeline:

```groovy
javaEKSPipeline()
```

Stages:

```text
1. Checkout

2. Maven Build

3. Unit Tests

4. Package JAR

5. Docker Build

6. Push to ECR

7. Helm Deployment
```

---

## Frontend Pipeline

Stages:

```text
1. Checkout

2. Build Nginx Image

3. Push to ECR

4. Helm Deployment
```

---

# ECR Integration

Login:

```bash
aws ecr get-login-password \
| docker login \
--username AWS \
--password-stdin ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com
```

Tag:

```bash
docker tag catalogue:v1 \
ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/catalogue:v1
```

Push:

```bash
docker push \
ACCOUNT_ID.dkr.ecr.ap-south-1.amazonaws.com/catalogue:v1
```

---

# Deployment Flow

```text
GitHub Push
      │
      ▼

Jenkins Trigger
      │
      ▼

Build Application
      │
      ▼

Docker Image
      │
      ▼

Amazon ECR
      │
      ▼

Helm Chart
      │
      ▼

Amazon EKS
      │
      ▼

Application Running
```

---

# Verification

```bash
kubectl get pods

kubectl get deploy

kubectl get svc

kubectl get ingress
```

Expected:

```text
frontend
catalogue
user
cart
shipping
payment
```

All pods:

```text
Running
```

---

# Troubleshooting

## CrashLoopBackOff

```bash
kubectl logs POD_NAME
```

## ImagePullBackOff

```bash
kubectl describe pod POD_NAME
```

Check:

* ECR permissions
* Image tags
* Repository exists

## Jenkins Failure

Verify:

```text
Shared Library

AWS Credentials

GitHub Credentials

Docker Daemon
```

## Deployment Failure

```bash
kubectl describe deployment APP_NAME
```

---

# End-to-End Platform Flow

```text
Terraform
    │
    ▼

AWS Infrastructure
    │
    ▼

Amazon EKS
    │
    ▼

Helm Charts
    │
    ▼

Jenkins
    │
    ▼

Docker Images
    │
    ▼

Amazon ECR
    │
    ▼

Microservices
    │
    ▼

RoboWorld Application
```


