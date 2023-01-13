targetScope = 'subscription'

// ----------
// PARAMETERS
// ----------

@allowed(['Dev','Prod','QA','Stage','Test'])
@description('Deployment environment of the application, workload, or service.')
param env string

@description('Azure Region where the resources will be located.')
param location string = deployment().location

param name string

@description('ISO 8601 format datetime when the application, workload, or service was first deployed.')
param startDate string = dateTimeAdd(utcNow(),'-PT5H','G')

@description('When creating Spoke VNet, you must specify a custom private IP address space using public and private (RFC 1918) addresses.')
param vnetSpokeAddressSpace object

@description('Subnets to segment Spoke VNet into one or more sub-networks and allocate a portion of the address space to each subnet.')
param vnetSpokeSubnets array

// ---------
// VARIABLES
// ---------

var kvName = toLower('kv-${uniqueString(rg.id)}')

var tags = {
  Env: env
  StartDate: startDate
}

// ---------
// RESOURCES
// ---------

// AADSSHLoginForLinux Virtual Machine Extension
module AADSSHLoginForLinux 'modules/extension.bicep' = {
  // Linked Deployment Name
  name: 'VirtualMachineExtension'
  params: {
    vmName: vm.outputs.name
    extensionName: 'AADSSHLoginForLinux'
    location: location
    tags: tags
  }
  scope: rg
}

// Reference to Key Vault
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  // Name of Existing Key Vault
  name: kvName
  scope: rg
}

// Network Interface
module nic 'modules/nic.bicep' = {
  // Linked Deployment Name
  name: 'NetworkInterface'
  params: {
    location: location
    name: 'nic-${name}-${env}'
    nsgID: nsg.outputs.ID
    pipID: pip.outputs.ID
    snetID: vnetSpoke.outputs.subnets[0].id
  }
  scope: rg
}

// Network Security Group
module nsg 'modules/nsg.bicep' = {
  // Linked Deployment Name
  name: 'NetworkSecurityGroup'
  params: {
    location: location
    name: 'nsg-${name}-${env}'
  }
  scope: rg
}

// Public IP Address
module pip 'modules/pip.bicep' = {
  // Linked Deployment Name
  name: 'PublicIPAddress'
  params: {
    location: location
    name: 'pip-${name}-${env}'
    tags: tags
  }
  scope: rg
}

// Reference to Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  // Name of Existing Resource Group
  name: 'rg-${name}-${env}'
}

// Virtual Machine
module vm 'modules/vm.bicep' = {
  // Linked Deployment Name
  name: 'VirtualMachine'
  params: {
    location: location
    name: 'vm${name}'
    nicID: nic.outputs.id
    sshKey: kv.getSecret('ssh-pub')
    tags: tags
  }
  scope: rg
}

// Spoke virtual network that isolates workload
module vnetSpoke 'modules/vnet.bicep' = {
  // Linked Deployment Name
  name: 'VirtualNetwork-Spoke'
  params: {
    addressSpace: vnetSpokeAddressSpace
    location: location
    name: 'spoke-${name}-${env}'
    subnets: vnetSpokeSubnets
    tags: tags
  }
  scope: rg
}
