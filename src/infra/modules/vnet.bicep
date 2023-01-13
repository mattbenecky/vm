// ----------
// PARAMETERS
// ----------

@description('When creating VNet, you must specify a custom private IP address space using public and private (RFC 1918) addresses.')
param addressSpace object 

param location string =  resourceGroup().location
param name string

@description('Subnets to segment VNet into one or more sub-networks and allocate a portion of the address space to each subnet.')
param subnets array

param tags object 

// ---------
// VARIABLES
// ---------

var virtualNetwork = {
  enableDdosProtection: false
  location: location
  name: 'vnet-${name}'
}

// ---------
// RESOURCES
// ---------

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  location: virtualNetwork.location
  name: virtualNetwork.name
  properties: {
    addressSpace: addressSpace 
    subnets: [for subnet in subnets: {
      name: '${subnet.name}'
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        delegations: contains(subnet, 'delegation') ? subnet.delegation : []
        privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : null
        privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : null
      }
    }]
    enableDdosProtection: virtualNetwork.enableDdosProtection
  }
  tags: tags
}

// -------
// OUTPUTS
// -------

output vnetID string = vnet.id
output vnetName string = vnet.name

output ID object = {
  id: vnet.id
}

output subnets array = [for (subnet, i) in subnets: {
  id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, vnet.properties.subnets[i].name)
}]
