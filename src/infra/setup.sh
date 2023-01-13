#!/bin/sh

# Input GitHub username variable to configure OIDC federated credential parameters
read -p "Enter GitHub username: " GITHUB_USER

# Install extensions automatically by enabling dynamic install without a prompt
az config set extension.use_dynamic_install=yes_without_prompt
SIGNED_IN_USER_ID=$(az ad signed-in-user show --query "[id]" -o tsv)
SUBSCRIPTION_ID=$(az account show --query "[id]" -o tsv)
TENANT_ID=$(az account show --query "[tenantId]" -o tsv)
SUBSCRIPTION_SCOPE=$(az account subscription show --id $SUBSCRIPTION_ID --query "[id]" | tr -d '[]" \n')

# Create Azure AD App Registration for Deployment Principal 
az ad app create --display-name "Deployment Principal"
DEPLOYMENT_APP_OBJECT_ID=$(az ad app list --display-name "Deployment Principal" --query "[0].[id]" -o tsv)
DEPLOYMENT_APP_ID=$(az ad app list --display-name "Deployment Principal" --query "[0].[appId]" -o tsv)

# Create federated credential for OIDC token authentication
az ad app federated-credential create \
   --id $DEPLOYMENT_APP_OBJECT_ID \
   --parameters "{\"name\":\"id-deployment-principal\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_USER}/vm:environment:Dev\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

# Create Azure AD Service Principal to add role assignments with necessary permisions for Deployment Principal
az ad sp create --id $DEPLOYMENT_APP_OBJECT_ID
DEPLOYMENT_SP_OBJECT_ID=$(az ad sp list --display-name "Deployment Principal" --query "[0].[id]" -o tsv)
az role assignment create \
  --assignee-object-id $DEPLOYMENT_SP_OBJECT_ID \
  --assignee-principal-type "ServicePrincipal" \
  --role Contributor \
  --scope $SUBSCRIPTION_SCOPE
az role assignment create \
  --assignee-object-id $DEPLOYMENT_SP_OBJECT_ID \
  --assignee-principal-type "ServicePrincipal" \
  --role "Virtual Machine Administrator Login" \
  --scope $SUBSCRIPTION_SCOPE
az role assignment create \
  --assignee-object-id $DEPLOYMENT_SP_OBJECT_ID \
  --assignee-principal-type "ServicePrincipal" \
  --role "Role Based Access Control Administrator (Preview)" \
  --scope $SUBSCRIPTION_SCOPE
az role assignment create \
  --assignee-object-id $DEPLOYMENT_SP_OBJECT_ID \
  --assignee-principal-type "ServicePrincipal" \
  --role "Key Vault Secrets Officer" \
  --scope $SUBSCRIPTION_SCOPE

echo -e "\nClick Settings -> Environments"
echo -e "\n+ New Environment: Dev"
echo -e "\nAdd the following GitHub Secrets:"
echo "════════════════════════════════════════════════════════════════════════"
echo "Name: CLIENT_ID         Value:" $DEPLOYMENT_APP_ID
echo "────────────────────────────────────────────────────────────────────────"
echo "Name: TENANT_ID         Value:" $TENANT_ID
echo "────────────────────────────────────────────────────────────────────────"
echo "Name: SUBSCRIPTION_ID   Value:" $SUBSCRIPTION_ID
echo "────────────────────────────────────────────────────────────────────────"