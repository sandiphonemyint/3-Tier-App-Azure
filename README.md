

# 🌐 Azure 3-Tier Infrastructure - CloudOps Goal Tracker App

Deploy a modern 3-tier application architecture on **Azure** using **Terraform** and **Docker**, featuring:

- **Frontend:** Node.js app on VMSS (public subnet)  
- **Backend:** Go API service on VMSS (private subnet)  
- **Database:** Azure PostgreSQL Flexible Server (private subnet)  

---

## ⚙️ Prerequisites

- Azure CLI  
- Terraform 
- Docker + Docker Hub account  
- Azure subscription with Contributor role  

---

## 🔐 Azure Service Principal Setup

```bash
# Step 1: Login to Azure
az login

# Step 2: Get your subscription ID
az account show --query id --output tsv

# Step 3: Create service principal with Contributor role
az ad sp create-for-rbac --name "terraform-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/<YOUR_SUBSCRIPTION_ID>"

# Output JSON will look like:
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "terraform-sp",
  "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

# Step 4: Set environment variables for Terraform
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"
export ARM_TENANT_ID="<tenant>"

# Step 5: Login using service principal (optional validation)
az login --service-principal \
  --username $ARM_CLIENT_ID \
  --password $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID
```
----
## 🚀 Deploy to Azure

```bash
# Step 1: Login to Docker Hub
docker login -u <YOUR_DOCKERHUB_USERNAME>

# Step 2: Build and push Docker images to Docker Hub
docker build -t <your_dockerhub_username>/frontend:latest ./frontend
docker build -t <your_dockerhub_username>/backend:latest ./backend
docker push <your_dockerhub_username>/frontend:latest
docker push <your_dockerhub_username>/backend:latest

# Step 3: Initialize and apply Terraform
cd infra
terraform init

terraform apply \
  -var="dockerhub_username=<your_dockerhub_username>" \
  -var="dockerhub_password=<your_dockerhub_pat>" \
  -var="frontend_image=<your_dockerhub_username>/frontend:latest" \
  -var="backend_image=<your_dockerhub_username>/backend:latest" \
  -var-file="environments/prod/terraform.tfvars"

# Step 4: Get output values
echo "Frontend URL: http://$(terraform output -raw frontend_public_ip)"
echo "Backend Internal: http://$(terraform output -raw backend_internal_lb_ip):8080"
echo "Database Host: $(terraform output -raw postgres_server_fqdn)"
```
---
## 🌐 Access the Application

```bash
# Frontend: Access via Application Gateway public IP
echo "Frontend URL: http://$(terraform output -raw frontend_public_ip)"

# Backend: Access via internal load balancer (inside VNet)
echo "Backend Internal Endpoint: http://$(terraform output -raw backend_internal_lb_ip):8080"

# Database: PostgreSQL FQDNs (Private Endpoint)
echo "PostgreSQL Primary Server: $(terraform output -raw postgres_server_fqdn)"
echo "PostgreSQL Read Replica: $(terraform output -raw postgres_replica_name)"

# SSH Access: Extract SSH private keys to access VMs through Azure Bastion
terraform output -raw frontend_ssh_private_key > frontend_key.pem
terraform output -raw backend_ssh_private_key > backend_key.pem
chmod 400 frontend_key.pem backend_key.pem
```
---
## Project Structure

```.
├── frontend/          # Node.js UI
├── backend/           # Go API
└── infra/             # Terraform IaC
    ├── modules/       # VNet, Compute, DB, etc.
    └── environments/  # Environment-specific vars

```
---
## Cleanup

To destroy the infrastructure when no longer needed:

```bash
terraform destroy -auto-approve
```
---
## License

MIT © 2025
