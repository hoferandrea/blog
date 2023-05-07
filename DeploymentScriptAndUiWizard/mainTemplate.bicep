param uamiName string = 'mi-deploymentScript-10'
param userPrincipalName string = 'john.contoso@hoferlabs.ch'
param userDisplayName string = 'John Contoso'
param groupName string = 'Sales'
param groupDescription string = 'Sales Group'
param storageAccountName string = 'sahoferlabssales'
param storageAccountType string = 'Standard_LRS'
param storageAccountFileShareName string = 'fshoferlabssales'
param targetResourceGroup string = 'rg-target-10'

targetScope = 'resourceGroup'

// describe deployment script for the AAD user
module deploymentScriptAadUser 'modules/createAadUser.bicep' = {
  name: 'aadUserDeployment'
  dependsOn: []
  params: {
    uamiName: uamiName
    userPrincipalName: userPrincipalName
    userDisplayName: userDisplayName
  }
}

// describe deployment script for the AAD group
module deploymentScriptAadGroup 'modules/createAadGroup.bicep' = {
  name: 'aadGroupDeployment'
  dependsOn: [ deploymentScriptAadUser ]
  params: {
    uamiName: uamiName
    groupName: groupName
    groupDescription: groupDescription
  }
}

// describe deployment script for the AAD group membership
module deploymentScriptAadGroupMembership 'modules/assignAadGroupMembershipToUser.bicep' = {
  name: 'aadGroupMembershipDeployment'
  dependsOn: [ deploymentScriptAadGroup ]
  params: {
    uamiName: uamiName
    userId: deploymentScriptAadUser.outputs.userId
    groupId: deploymentScriptAadGroup.outputs.groupId
  }
}

// describe storage account
module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccountDeployment'
  dependsOn: []
  scope: resourceGroup(targetResourceGroup)
  params: {
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
  }
}

// describe file share
module storageAccountFileShare 'modules/storageAccountFileShare.bicep' = {
  name: 'storageAccountFileShareDeployment'
  dependsOn: [ storageAccount ]
  scope: resourceGroup(targetResourceGroup)
  params: {
    storageAccountName: storageAccountName
    storageAccountFileShareName: storageAccountFileShareName
  }
}

// describe storage account permissions
module storageAccountAzureRoleAssignment 'modules/storageAccountRoleAssignment.bicep' = {
  name: 'storageAccountAzureRoleAssignmentDeployment'
  dependsOn: [ deploymentScriptAadGroup, storageAccountFileShare ]
  scope: resourceGroup(targetResourceGroup)
  params: {
    prinipalId: deploymentScriptAadGroup.outputs.groupId
    roleDefinitionId: '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb' // Storage File Data SMB Share Contributor
    storageAccountName: storageAccountName

  }
}
