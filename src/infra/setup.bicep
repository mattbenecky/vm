targetScope = 'subscription'

// ----------
// PARAMETERS
// ----------

@allowed(['Dev','Prod','QA','Stage','Test'])
@description('Deployment environment of the application, workload, or service.')
param env string

param location string = deployment().location

param name string

@description('ISO 8601 format datetime when the application, workload, or service was first deployed.')
param startDate string = dateTimeAdd(utcNow(),'-PT5H','G')

// ---------
// VARIABLES
// ---------

var tags = {
  Env: env
  StartDate: startDate
}

// ---------
// RESOURCES
// ---------

// User-Assigned Managed Identity for Deployment Script
module idScript 'modules/id.bicep' = {
  // Linked Deployment Name
  name: 'UserAssignedIdentityScript'
  params: {
    location: location
    name: 'id-script-${env}'
  }
  scope: rg
}

// Key Vault
module kv 'modules/kv.bicep' = {
  // Linked Deployment Name
  name: 'KeyVault'
  params: {
    location: location
  }
  scope: rg
}

// Resource group is a container that holds related resources for an Azure solution
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: 'rg-${name}-${env}'
  tags: tags
}

// Assign Contributor role to Deployment Script Managed Identity (idScript)
module roleContributor 'modules/role.bicep' = {
  // Linked Deployment Name
  name: 'ContributorRoleAssignment'
  // Parameter Names and Values
  params: {
    name: guid(subscription().id, 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: idScript.outputs.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions','b24988ac-6180-42a0-ab88-20f7382dd24c')
  }
  scope: rg
}

// Assign Key Vault Secrets Officer role to Deployment Script Managed Identity (idScript)
module roleKeyVaultSecretsOfficer 'modules/role.bicep' = {
  // Linked Deployment Name
  name: 'KeyVaultSecretsOfficer'
  // Parameter Names and Values
  params: {
    name: guid(subscription().id, 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
    principalId: idScript.outputs.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions','b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  }
  scope: rg
}

// Deployment Script to generate SSH key pair and add secrets to Key Vault
module script 'modules/script.bicep' = {
  dependsOn: [roleContributor,roleKeyVaultSecretsOfficer]
  //Linked Deployment Name
  name: 'DeploymentScript'
  // Parameter Names and Values
  params: {
    kvName: kv.outputs.name
    location: location
    name: 'script-${name}-${env}'
    userAssignedID: idScript.outputs.userAssignedID
  }
  scope: rg
}
