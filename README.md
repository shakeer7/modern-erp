# UNiPiper - Microservices Application

UNiPiper is a scalable, microservices-based college application platform. This repository contains the complete source code, infrastructure as code (Terraform), and Kubernetes deployment configurations, including a zero-downtime Blue-Green deployment pipeline.

## Architecture Overview

- **Frontend**: Lightweight HTML/CSS/JS frontend application.
- **Auth Service**: Python FastAPI backend handling user registration, authentication, and JWT token generation.
- **Database**: MySQL database running inside the Kubernetes cluster.
- **Infrastructure**: AWS Elastic Kubernetes Service (EKS) and AWS Elastic Container Registry (ECR), provisioned via Terraform.
- **Ingress**: NGINX Ingress Controller routing traffic with self-signed SSL/TLS support.
- **CI/CD**: Fully automated GitHub Actions pipeline featuring a robust Blue-Green deployment strategy.

## Repository Structure

- `/frontend` - Source code and Dockerfile for the frontend.
- `/auth-service` - Source code and Dockerfile for the Python FastAPI authentication service.
- `/terraform/prod` - Infrastructure as Code (Terraform) to provision AWS resources.
- `/k8s` - Kubernetes manifests (Ingress, Services, MySQL) and Blue-Green deployment templates.
- `/scripts` - Automation scripts, including the `deploy-blue-green.sh` script.
- `.github/workflows` - CI/CD pipeline definitions.

## End-to-End Setup Guide

### 1. Prerequisites
Ensure you have the following installed locally:
- [AWS CLI](https://aws.amazon.com/cli/) (configured with an admin user)
- [Terraform](https://www.terraform.io/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Docker](https://docs.docker.com/get-docker/)

### 2. Provision AWS Infrastructure (Terraform)
Navigate to the Terraform directory and deploy the infrastructure:

```bash
cd terraform/prod
terraform init
terraform apply
```
*Note: Type `yes` when prompted. This provisions a VPC, an EKS cluster (`college-app-cluster`), and ECR repositories.* 

After completion, configure your local `kubectl` to connect to the new cluster:
```bash
aws eks update-kubeconfig --region ap-south-1 --name college-app-cluster
```

### 3. Setup CI/CD Secrets
For GitHub Actions to successfully build and deploy your app, you must add AWS credentials to your GitHub repository secrets:
1. Go to your GitHub repository **Settings** -> **Secrets and variables** -> **Actions**.
2. Add `AWS_ACCESS_KEY_ID`
3. Add `AWS_SECRET_ACCESS_KEY`

### 4. Deploy the Application
The deployment process is fully automated. Simply push your code to the `main` branch:

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

### 5. How Blue-Green Deployment Works
When you push new code to `main`:
1. GitHub Actions builds your new Docker images and pushes them to AWS ECR.
2. The `deploy-blue-green.sh` script detects which environment is currently "live" (e.g., `blue`).
3. It deploys the fresh code to the inactive environment (`green`).
4. It waits until Kubernetes reports that the `green` pods are 100% healthy and ready.
5. It patches the Kubernetes Service to seamlessly route all live traffic to `green`, resulting in **zero downtime**.
6. It scales down the old `blue` pods to save resources.

### 6. Accessing the Application
To find your live application URL, run:
```bash
kubectl get ingress
```
Copy the `ADDRESS` (e.g., `xxx.elb.ap-south-1.amazonaws.com`).

> **Note:** The application uses a self-signed SSL certificate for `unipiper.local`. To view the site securely, use `https://<YOUR-ELB-ADDRESS>` and accept the browser's security warning.
