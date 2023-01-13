// ----------
// PARAMETERS
// ----------

param name string
param principalId string

@description('Type of Security Principal for the Role Assignment.')
@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string

param roleDefinitionId string

// ---------
// RESOURCES
// ---------

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: name
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinitionId
  }
}
