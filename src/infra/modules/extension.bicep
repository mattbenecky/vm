// ----------
// PARAMETERS
// ----------

@description('Auto-Upgrade Minor Version for the Virtual Machine Extension.')
param autoUpgradeMinorVersion bool = loadJsonContent('../variables/extension.json', 'autoUpgradeMinorVersion')

@description('Name of the Virtual Machine Extension.')
param extensionName string

@description('Type for the Virtual Machine Extension.')
param extensionType string = loadJsonContent('../variables/extension.json', 'extensionType')

param location string 

@description('Publisher for the Virtual Machine Extension.')
param publisher string = loadJsonContent('../variables/extension.json', 'publisher')

param tags object

@description('Type Handler Version for the Virtual Machine Extension.')
param typeHandlerVersion string = loadJsonContent('../variables/extension.json', 'typeHandlerVersion')

@description('Name of the Virtual Machine.')
param vmName string

// ---------
// VARIABLES
// ---------

// Format for Virtual Machine Extension Name '<VM Name>/<VM Extension Name>'
var name = '${vmName}/${extensionName}'

var properties = {
  autoUpgradeMinorVersion: autoUpgradeMinorVersion
  protectedSettings: {}
  publisher: publisher
  settings: {}
  type: extensionType
  typeHandlerVersion: typeHandlerVersion
}

// ---------
// RESOURCES
// ---------

resource extension 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  location: location
  name: name
  properties: properties
  tags: tags
}
