param roleDefinitionId string
param prinipalId string
param storageAccountName string 

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

// describe the role assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(roleDefinitionId, prinipalId)
  //scope: scope
  scope: storageAccount
  properties:{
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${roleDefinitionId}'
    principalId: prinipalId
  }
}