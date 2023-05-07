param uamiName string
param userId string
param groupId string
param utcValue string = utcNow()
param location string = resourceGroup().location

// reference the user-assigned managed identity
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: uamiName
  scope: resourceGroup()

}

// describe the deployment script
// use the current time in the name, otherwise the script isn't triggered again 
resource assignAadGroupMembershipToUser 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'assignAadGroupMembershipToUser-${utcValue}'
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
    scriptContent: loadTextContent('assignAadGroupMembershipToUser.ps1')
    arguments: '-userId \\"${userId}\\" -groupId \\"${groupId}\\"'
    retentionInterval: 'P1D'
    cleanupPreference: 'OnExpiration'
  }
}

output result string = assignAadGroupMembershipToUser.properties.outputs.result

