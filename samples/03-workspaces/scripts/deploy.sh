#!/usr/bin/env bash

set -e

echo "Initializing Terraform..."
terraform init

echo "Selecting Terraform Workspace ($DEPLOY_WORKSPACE)..."
terraform workspace select $DEPLOY_WORKSPACE

echo "Validating Terraform Format..."
terraform fmt -check

echo "Planning Terraform Deployment..."
terraform plan

echo "Applying Terraform Deployment..."
terraform apply -auto-approve