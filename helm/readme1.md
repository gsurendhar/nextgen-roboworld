

# Helm Deployment README 

# 🚀 NextGen RoboWorld Kubernetes Deployment Guide

## Overview

This repository contains Helm charts used to deploy the NextGen RoboWorld application onto Amazon EKS.

The deployment consists of:

### Infrastructure Layer

* Amazon EKS
* StorageClass
* Persistent Volumes

### Data Layer

* MongoDB
* MySQL
* Redis
* RabbitMQ

### Application Layer

* Frontend
* Catalogue
* Cart
* User
* Payment
* Shipping

---

# Architecture

```text
                        Internet
                            │
                            ▼
                   Application Load Balancer
                            │
                            ▼
                         Frontend
                            │
      ┌─────────────┬─────────────┬─────────────┐
      ▼             ▼             ▼             ▼

  Catalogue       User         Cart        Payment
      │             │             │             │
      └─────────────┼─────────────┴─────────────┘
                    │
                    ▼
                 Shipping

──────────────────────────────────────────

MongoDB    MySQL    Redis    RabbitMQ

──────────────────────────────────────────

Amazon EKS Cluster
```

---

# Helm Repository Structure

```text
helm/
│
├── namespace.yaml
├── storageClass.yaml
├── sc.yaml
│
├── mongodb/
├── mysql/
├── redis/
├── rabbitmq/
│
├── frontend/
├── catalogue/
├── cart/
├── user/
├── payment/
└── shipping/
```

---

# Prerequisites

Before deploying applications, ensure:

✅ AWS Infrastructure deployed

✅ EKS Cluster running

✅ kubectl installed

✅ Helm installed

---

# Verify Cluster Access

Check nodes:

```bash
kubectl get nodes
```

Expected:

```text
NAME             STATUS
worker-node-1    Ready
worker-node-2    Ready
```

---

# Install Helm

Verify:

```bash
helm version
```

Expected:

```text
version.BuildInfo
```

---

# Step 1 - Create Namespace

Deploy namespace:

```bash
kubectl apply -f namespace.yaml
```

Verify:

```bash
kubectl get ns
```

Expected:

```text
roboshop
```

---

# Step 2 - Create Storage Class

Deploy:

```bash
kubectl apply -f storageClass.yaml
```

or

```bash
kubectl apply -f sc.yaml
```

Verify:

```bash
kubectl get storageclass
```

Expected:

```text
gp3
```

---

# Deployment Order

Deploy exactly in this sequence.

```text
1. MongoDB
2. MySQL
3. Redis
4. RabbitMQ

5. Catalogue
6. User
7. Cart
8. Shipping
9. Payment

10. Frontend
```

---

# Step 3 - Deploy MongoDB

Navigate:

```bash
cd mongodb
```

Install:

```bash
helm install mongodb .
```

Verify:

```bash
kubectl get pods
```

Expected:

```text
mongodb-0
mongodb-1
```

Type:

```text
StatefulSet
```

Replicas:

```text
2
```

Image:

```text
gsurendhar/mongodb:v1
```

---

# Step 4 - Deploy MySQL

```bash
cd ../mysql

helm install mysql .
```

Verify:

```bash
kubectl get pods
```

Expected:

```text
mysql-0
mysql-1
```

---

# Step 5 - Deploy Redis

```bash
cd ../redis

helm install redis .
```

Verify:

```bash
kubectl get pods
```

Expected:

```text
redis-0
redis-1
```

---

# Step 6 - Deploy RabbitMQ

```bash
cd ../rabbitmq

helm install rabbitmq .
```

Verify:

```bash
kubectl get pods
```

Expected:

```text
rabbitmq-0
rabbitmq-1
```

---

# Verify Data Layer

```bash
kubectl get pods
```

Expected:

```text
mongodb
mysql
redis
rabbitmq
```

All should be:

```text
Running
```

---

# Step 7 - Deploy Catalogue Service

```bash
cd ../catalogue

helm install catalogue .
```

Configuration:

```yaml
imageURL: gsurendhar/catalogue
imageVersion: v2
```

Verify:

```bash
kubectl get deploy
```

---

# Step 8 - Deploy User Service

```bash
cd ../user

helm install user .
```

Verify:

```bash
kubectl get deploy
```

---

# Step 9 - Deploy Cart Service

```bash
cd ../cart

helm install cart .
```

Verify:

```bash
kubectl get deploy
```

---

# Step 10 - Deploy Shipping Service

```bash
cd ../shipping

helm install shipping .
```

Verify:

```bash
kubectl get deploy
```

---

# Step 11 - Deploy Payment Service

```bash
cd ../payment

helm install payment .
```

Configuration:

```yaml
imageURL: gsurendhar/payment
imageVersion: v2
```

Verify:

```bash
kubectl get deploy
```

---

# Step 12 - Deploy Frontend

```bash
cd ../frontend

helm install frontend .
```

Configuration:

```yaml
imageURL: gsurendhar/frontend
imageVersion: v2
```

Verify:

```bash
kubectl get deploy
```

---

# Verify Complete Application

Pods:

```bash
kubectl get pods
```

Services:

```bash
kubectl get svc
```

Deployments:

```bash
kubectl get deploy
```

HPA:

```bash
kubectl get hpa
```

---

# Autoscaling

Application services include HPA.

Current configuration:

```yaml
maxReplicas: 5
utilization: 80
```

Meaning:

```text
Scale up when CPU > 80%

Maximum Pods = 5
```

---

# Helm Upgrade

Example:

```bash
helm upgrade frontend .
```

Upgrade image:

```yaml
imageVersion: v3
```

Then:

```bash
helm upgrade frontend .
```

---

# Helm Rollback

View revisions:

```bash
helm history frontend
```

Rollback:

```bash
helm rollback frontend 1
```

---

# Troubleshooting

Check Pods:

```bash
kubectl get pods
```

Describe Pod:

```bash
kubectl describe pod POD_NAME
```

Logs:

```bash
kubectl logs POD_NAME
```

Events:

```bash
kubectl get events
```

---

# Verify Application Dependencies

```text
Frontend
 │
 ├── Catalogue
 ├── User
 ├── Cart
 ├── Shipping
 └── Payment

Catalogue → MongoDB

User → MongoDB

Cart → Redis

Payment → RabbitMQ

Shipping → MySQL
```

---

# Uninstall Application

Reverse order:

```bash
helm uninstall frontend

helm uninstall payment

helm uninstall shipping

helm uninstall cart

helm uninstall user

helm uninstall catalogue

helm uninstall rabbitmq

helm uninstall redis

helm uninstall mysql

helm uninstall mongodb
```

---

# Production Recommendations

* Use AWS Load Balancer Controller
* Enable Ingress
* Use External DNS
* Enable Monitoring
* Enable Prometheus
* Enable Grafana
* Enable EFK Logging
* Enable TLS
* Store secrets in AWS Secrets Manager
* Enable Backup Strategy

---

# Final Deployment Flow

```text
Infrastructure
      │
      ▼

Amazon EKS
      │
      ▼

StorageClass
      │
      ▼

MongoDB
MySQL
Redis
RabbitMQ
      │
      ▼

Catalogue
User
Cart
Shipping
Payment
      │
      ▼

Frontend
      │
      ▼

Application Available
```
