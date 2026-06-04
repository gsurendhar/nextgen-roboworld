#  NextGen RoboWorld Kubernetes Deployment Guide

# 1. Overview

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

# 2. Architecture Diagram

```text
Internet
    │
    ▼
AWS Load Balancer
    │
    ▼
Frontend
    │
 ┌──┼────┬─────┬─────┐
 ▼  ▼    ▼     ▼     ▼

Catalogue User Cart Payment Shipping

 │         │     │      │
 ▼         ▼     ▼      ▼

MongoDB  MongoDB Redis RabbitMQ MySQL
```

---

# 3. Prerequisites

Before deployment verify:

```bash
kubectl get nodes
helm version
```

Expected:

```text
2 Ready Nodes
```

---

# 4. Repository Structure

```text
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

# 5. Application Dependency Diagram

```text
Frontend
│
├── Catalogue ──► MongoDB
│
├── User ───────► MongoDB
│
├── Cart ───────► Redis
│
├── Payment ────► RabbitMQ
│
└── Shipping ───► MySQL
```

This section is extremely important because beginners need to understand why deployment order matters.

---

# 6. Create Namespace

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

# 7. Create Storage Class

```bash
kubectl apply -f storageClass.yaml
```

Verify:

```bash
kubectl get storageclass
```

---

# 8. Deploy Databases First

## MongoDB

```bash
cd mongodb

helm install mongodb .
```

Verify:

```bash
kubectl get pods
```

Expected:

```text
mongodb-0 Running
mongodb-1 Running
```

---

## MySQL

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
mysql-0 Running
mysql-1 Running
```

---

## Redis

```bash
cd ../redis

helm install redis .
```

---

## RabbitMQ

```bash
cd ../rabbitmq

helm install rabbitmq .
```

---

# 9. Verify Database Layer

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

All pods should show:

```text
STATUS = Running
```

Do not continue until all are healthy.

---

# 10. Deploy Backend Services

Deploy one by one.

## Catalogue

```bash
cd ../catalogue

helm install catalogue .
```

Verify:

```bash
kubectl get deploy catalogue
```

---

## User

```bash
cd ../user

helm install user .
```

---

## Cart

```bash
cd ../cart

helm install cart .
```

---

## Shipping

```bash
cd ../shipping

helm install shipping .
```

---

## Payment

```bash
cd ../payment

helm install payment .
```

---

# 11. Verify Backend Layer

```bash
kubectl get deploy
```

Expected:

```text
catalogue
user
cart
shipping
payment
```

All should be:

```text
AVAILABLE = 1
```

---

# 12. Deploy Frontend

```bash
cd ../frontend

helm install frontend .
```

Verify:

```bash
kubectl get deploy frontend
```

---

# 13. Verify Complete Application

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

Ingress:

```bash
kubectl get ingress
```

---

# 14. Access Application

Find Load Balancer:

```bash
kubectl get ingress
```

Example:

```text
frontend.gonela.site
```

Open:

```text
https://frontend.gonela.site
```

---

# 15. Troubleshooting

### Pod CrashLoopBackOff

```bash
kubectl logs POD_NAME
```

### Pod Pending

```bash
kubectl describe pod POD_NAME
```

Check:

* StorageClass
* PVC
* Resources

### Database Connectivity

```bash
kubectl get svc
```

Verify:

```text
mongodb
mysql
redis
rabbitmq
```

exist before deploying application services.

### Image Pull Errors

```bash
kubectl describe pod POD_NAME
```

Check:

* Image Name
* Image Tag
* ECR Access

---

# 16. Upgrade Service

Example:

```bash
helm upgrade frontend .
```

---

# 17. Rollback Service

```bash
helm history frontend
```

Rollback:

```bash
helm rollback frontend 1
```

---

# 18. Uninstall Application

Reverse order.

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

# 19. Production Checklist

```text
☐ HTTPS Enabled

☐ ACM Certificate Valid

☐ Route53 Configured

☐ AWS Load Balancer Controller Installed

☐ ExternalDNS Installed

☐ Monitoring Enabled

☐ Prometheus Installed

☐ Grafana Installed

☐ Logging Enabled

☐ Backups Configured

☐ Resource Limits Added

☐ HPA Enabled

☐ Secrets Managed Securely
```

---

# 20. End-to-End Deployment Flow

```text
Terraform Infrastructure
        │
        ▼

Amazon EKS
        │
        ▼

Namespace
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

Application Live
```

