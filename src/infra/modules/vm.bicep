// ----------
// PARAMETERS
// ----------

@description('Admin Username for the Virtual Machine.')
param adminUsername string = loadJsonContent('../variables/vm.json', 'adminUsername')

@description('Create Option for the Virtual Machine.')
param createOption string = loadJsonContent('../variables/vm.json', 'createOption')

@description('Disable Password Authentication for the Virtual Machine.')
param disablePasswordAuthentication bool = loadJsonContent('../variables/vm.json', 'disablePasswordAuthentication')

@description('Azure Region where the Virtual Machine will be located.')
param location string =  resourceGroup().location

@description('Name for the Virtual Machine.')
param name string

@description('Resource ID of the Network Interface.')
param nicID string

@description('Offer for the Virtual Machine Image.')
param offer string = loadJsonContent('../variables/vm.json', 'offer')

@description('Disk Type for the Virtual Machine.')
param osDiskType string = loadJsonContent('../variables/vm.json', 'osDiskType')

@description('Publisher for the Virtual Machine Image.')
param publisher string = loadJsonContent('../variables/vm.json', 'publisher')

@description('SSH Key for the Virtual Machine.')
@secure()
param sshKey string

param tags object 

@description('Ubuntu OS Version for the Virtual Machine.')
@allowed([
  '12.04.5-LTS'
  '14.04.5-LTS'
  '16.04.0-LTS'
  '18.04-LTS'
  '20.04-LTS'
  '22_04-lts-gen2'
])
param ubuntuOSVersion string = loadJsonContent('../variables/vm.json', 'ubuntuOSVersion')

@description('Version for the Virtual Machine Image.')
param version string = loadJsonContent('../variables/vm.json', 'version')

@description('The SKU for the Virtual Machine.')
param vmSize string = loadJsonContent('../variables/vm.json', 'vmSize')

// ---------
// VARIABLES
// ---------

var linuxConfiguration = {
  disablePasswordAuthentication: disablePasswordAuthentication
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: sshKey
      }
    ]
  }
}

var hardwareProfile = {
  vmSize: vmSize
}

var storageProfile = {
  osDisk: {
    createOption: createOption
    managedDisk: {
      storageAccountType: osDiskType
    }
  }
  imageReference: {
    publisher: publisher
    offer: offer
    sku: ubuntuOSVersion
    version: version
  }
}

var networkProfile = {
  networkInterfaces: [
    {
      id: nicID
    }
  ]
}

var osProfile = {
  computerName: name
  adminUsername: adminUsername
  linuxConfiguration: linuxConfiguration
}

var identity = {
  type: 'SystemAssigned'
}

// ---------
// RESOURCES
// ---------

resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  identity: identity
  location: location
  name: name
  properties: {
    hardwareProfile: hardwareProfile
    storageProfile: storageProfile
    networkProfile: networkProfile
    osProfile: osProfile
  }
  tags: tags
}

// -------
// OUTPUTS
// -------

output location string = vm.location
output name string = vm.name
