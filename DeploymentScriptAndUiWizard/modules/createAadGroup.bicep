param uamiName string
param groupName string
param groupDescription string
param utcValue string = utcNow()
param location string = resourceGroup().location

// reference the user-assigned managed identity
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: uamiName
  scope: resourceGroup()

}

// use the current time in the name, otherwise the script isn't triggered again 
resource createAadGroup 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createAadGroup-${utcValue}'
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    forceUpdateTag: utcValue
    scriptContent: loadTextContent('createAadGroup.ps1')
    arguments: '-groupName \\"${groupName}\\" -groupDescription \\"${groupDescription}\\"'
    retentionInterval: 'P1D'
    cleanupPreference: 'OnExpiration'
  }
}

output groupId string = createAadGroup.properties.outputs.groupId
output result string = createAadGroup.properties.outputs.result

