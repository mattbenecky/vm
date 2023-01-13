// ----------
// PARAMETERS
// ----------

@description('Globally Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('vmdemo-${uniqueString(resourceGroup().id)}')

@description('Idle Timeout in Minutes for the Public IP Address.')
param idleTimeoutInMinutes int = loadJsonContent('../variables/pip.json', 'idleTimeoutInMinutes')

param location string = resourceGroup().location
param name string

@description('IP Address Version for the Public IP Address.')
param publicIPAddressVersion string = loadJsonContent('../variables/pip.json', 'publicIPAddressVersion')

@description('Allocation Method for the Public IP Address.')
param publicIPAllocationMethod string = loadJsonContent('../variables/pip.json', 'publicIPAllocationMethod')

@description('Allocation Method for the Public IP Address.')
param skuName string = loadJsonContent('../variables/pip.json', 'skuName')

param tags object 

// ---------
// VARIABLES
// ---------

var sku = {
  name: skuName
}

// ---------
// RESOURCES
// ---------

resource pip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  location: location
  name: name
  properties: {
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
    idleTimeoutInMinutes: idleTimeoutInMinutes
    publicIPAddressVersion: publicIPAddressVersion
    publicIPAllocationMethod: publicIPAllocationMethod
  }
  sku: sku
  tags: tags
}

// -------
// OUTPUTS
// -------

output ID string = pip.id
