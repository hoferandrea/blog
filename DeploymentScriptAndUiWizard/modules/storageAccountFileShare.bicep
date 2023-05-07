param storageAccountName string
param storageAccountFileShareName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}


resource fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-08-01' = {
  name: '${storageAccountName}/default/${storageAccountFileShareName}'
  properties: {
  }
}
