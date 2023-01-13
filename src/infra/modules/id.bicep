// ----------
// PARAMETERS
// ----------

param location string = resourceGroup().location
param name string

// ---------
// RESOURCES
// ---------

resource id 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  location: location
  name: name
 }

// -------
// OUTPUTS
// -------

 output userAssignedID string = id.id
 output principalId string = id.properties.principalId
 
 output ID object = {
  id: id.id
}
