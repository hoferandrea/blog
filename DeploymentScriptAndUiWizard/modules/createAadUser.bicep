param uamiName string
param userPrincipalName string
param userDisplayName string
param utcValue string = utcNow()
param location string = resourceGroup().location

// reference the user-assigned managed identity
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: uamiName
  scope: resourceGroup()

}

// describe the deployment script
// use the current time in the name, otherwise the script isn't triggered again 
resource createAadUser 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createAadUser-${utcValue}'
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
    scriptContent: loadTextContent('createAadUser.ps1')
    arguments: '-userPrincipalName \\"${userPrincipalName}\\" -userDisplayName \\"${userDisplayName}\\"'
    retentionInterval: 'P1D'
    cleanupPreference: 'OnExpiration'
  }
}

output userId string = createAadUser.properties.outputs.userId
output result string = createAadUser.properties.outputs.result

