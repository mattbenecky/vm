// ----------
// PARAMETERS
// ----------

param location string = resourceGroup().location
param name string = toLower('kv-${uniqueString(resourceGroup().id)}')

// ---------
// RESOURCES
// ---------

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  location: location
  name: name
  properties: {
    accessPolicies: []
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    enableSoftDelete: false
    tenantId: tenant().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    } 
  }
}

// -------
// OUTPUTS
// -------

output name string = kv.name
