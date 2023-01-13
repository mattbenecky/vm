// ----------
// PARAMETERS
// ----------

param forceUpdateTag string = utcNow()
param kvName string
param location string = resourceGroup().location
param name string
param userAssignedID string

// ---------
// VARIABLES
// ---------

var identity = {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '${userAssignedID}': {}
  }
}

// ---------
// RESOURCES
// ---------

resource script 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  identity: identity
  kind: 'AzureCLI'
  location: location
  name: name
  properties: {
    azCliVersion: '2.40.0'
    forceUpdateTag: forceUpdateTag
    timeout: 'PT30M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'kvName'
        value: kvName
      }
    ]
    scriptContent: '''
      mkdir -p .ssh/mykeys
      ssh-keygen -m PEM -t rsa -b 4096 -f .ssh/vmkey -q
      az keyvault secret set --vault-name $kvName --name "ssh-pem" --file .ssh/vmkey -o none
      az keyvault secret set --vault-name $kvName --name "ssh-pub" --file .ssh/vmkey.pub -o none
                '''
  }
}
