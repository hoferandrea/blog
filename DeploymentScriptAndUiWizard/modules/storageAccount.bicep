param storageAccountName string
param storageAccountType string
param location string = resourceGroup().location

// describe storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}

output storageAccountId string = storageAccount.id
