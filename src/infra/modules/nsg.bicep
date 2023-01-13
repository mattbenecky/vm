// ----------
// PARAMETERS
// ----------

param location string = resourceGroup().location
param name string

// ---------
// VARIABLES
// ---------

var securityRules = loadJsonContent('../variables/nsg.json', 'securityRules')

// ---------
// RESOURCES
// ---------

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  location: location
  name: name
  properties: {
    securityRules: securityRules
  }
}

// -------
// OUTPUTS
// -------

output ID string = nsg.id
