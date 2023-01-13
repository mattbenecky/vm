// ----------
// PARAMETERS
// ----------

@description('IP Configuration Name for the Network Interface.')
param ipConfigurationName string = loadJsonContent('../variables/nic.json', 'ipConfigurationName')

param location string = resourceGroup().location
param name string

@description('Network Security Group for the Network Interface.')
param nsgID string

@description('Public IP Address for the Network Interface.')
param pipID string

@description('Primary IP Configuration Enabled for the Network Interface.')
param primary bool = loadJsonContent('../variables/nic.json', 'primary')

@description('Private IP Address Version for the Network Interface.')
param privateIPAddressVersion string = loadJsonContent('../variables/nic.json', 'privateIPAddressVersion')

@description('Private IP Address Allocation Method for the Network Interface.')
param privateIPAllocationMethod string = loadJsonContent('../variables/nic.json', 'privateIPAllocationMethod')

@description('Subnet ID for the Network Interface.')
param snetID string

// ---------
// VARIABLES
// ---------

var publicIPAddress = {
  id: pipID
}

var subnet = {
  id: snetID
}

// ---------
// RESOURCES
// ---------

resource nic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  location: location
  name: name
  properties: {
    ipConfigurations: [
      {
        name: ipConfigurationName    
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          publicIPAddress: publicIPAddress
          subnet: subnet
          primary: primary
          privateIPAddressVersion: privateIPAddressVersion
        }
      }
    ]
    networkSecurityGroup: (!empty(nsgID)) ? {
      id: nsgID
    }: json('null')
  }
}

// -------
// OUTPUTS
// -------

output id string = nic.id
