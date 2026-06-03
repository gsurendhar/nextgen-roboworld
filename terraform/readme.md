

# NextGen RoboWorld Infrastructure (Terraform)



This repository contains Terraform code used to provision and manage the infrastructure for the NextGen RoboWorld platform.

## Architecture

The infrastructure provisions:

- AWS VPC
- Public and Private Subnets
- Internet Gateway
- NAT Gateway
- Security Groups
- EC2 Instances
- Application Load Balancer
- RDS Database
- ECS/EKS Cluster
- S3 Buckets
- IAM Roles and Policies
- CloudWatch Monitoring

## Prerequisites

Before deploying the infrastructure, ensure the following tools are installed:

### Terraform

Install Terraform:

https://developer.hashicorp.com/terraform/downloads

Verify installation:

```bash
terraform version
````


### AWS CLI

Install AWS CLI:

[https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Verify installation:

```bash
aws --version
```

### Configure AWS Credentials

```bash
aws configure
```

Provide:

```text
AWS Access Key ID
AWS Secret Access Key
Region
Output Format
```

## Project Structure

```text
terraform/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── backend.tf
├── terraform.tfvars
│
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   └── alb/
│
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

## Setup Instructions

### Step 1: Clone Repository

```bash
git clone https://github.com/gsurendhar/nextgen-roboworld.git

cd nextgen-roboworld/terraform
```

### Step 2: Initialize Terraform

```bash
terraform init
```

This downloads required providers and modules.

### Step 3: Validate Configuration

```bash
terraform validate
```

### Step 4: Review Execution Plan

```bash
terraform plan
```

### Step 5: Deploy Infrastructure

```bash
terraform apply
```

Approve when prompted:

```text
yes
```

### Step 6: Verify Resources

```bash
terraform state list
```

## Environment Variables

Create a tfvars file:

```hcl
aws_region = "us-east-1"

environment = "dev"

project_name = "nextgen-roboworld"
```

Deploy using:

```bash
terraform apply -var-file="terraform.tfvars"
```

## Terraform Commands

Initialize:

```bash
terraform init
```

Format Code:

```bash
terraform fmt
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Destroy:

```bash
terraform destroy
```

## Remote State Management

If using S3 backend:

```hcl
terraform {
  backend "s3" {
    bucket = "nextgen-roboworld-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
```

Reinitialize backend:

```bash
terraform init -reconfigure
```

## Outputs

View outputs:

```bash
terraform output
```

Examples:

```bash
terraform output vpc_id

terraform output alb_dns_name

terraform output cluster_name
```

## Deployment Workflow

```text
Developer
    ↓
Terraform Init
    ↓
Terraform Plan
    ↓
Terraform Apply
    ↓
AWS Infrastructure
    ↓
Application Deployment
```

## Cleanup

To remove all resources:

```bash
terraform destroy
```

## Troubleshooting

### Provider Authentication Error

```bash
aws sts get-caller-identity
```

### State Lock Error

```bash
terraform force-unlock LOCK_ID
```

### Refresh State

```bash
terraform refresh
```

## Security Best Practices

* Never commit AWS credentials.
* Store tfstate in S3 with versioning enabled.
* Use IAM Roles instead of static credentials.
* Enable encryption for S3 state storage.
* Use separate workspaces for environments.
