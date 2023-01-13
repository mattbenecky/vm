#!/bin/sh

az group delete -n "rg-demo-Dev" -y --force-deletion-types Microsoft.Compute/virtualMachines

# Delete Deployment Principal App Registration
DEPLOYMENT_OBJECT_ID=$(az ad app list --display-name "Deployment Principal" --query "[0].[id]" -o tsv)
az ad app delete --id $DEPLOYMENT_OBJECT_ID