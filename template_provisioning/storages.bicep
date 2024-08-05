param location string= resourceGroup().location
param storageAccesTier string = 'Hot'
param StorageSku string
param containerNames array = []
param cliente string
param env string



var Storagename= 'bajalatvalidat${cliente}${env}'
var Storagename2= 'plcolabnotifi${cliente}${env}'
var Storagename3= '${cliente}repext${env}'
var tablename = 'ConciliarEmisionesEnValidatingCommands'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' ={
  name: Storagename
  location: location
  sku: {
    name: StorageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: storageAccesTier
    minimumTlsVersion: 'TLS1_2'
  }

}

resource storageAccount2 'Microsoft.Storage/storageAccounts@2023-01-01' ={
  name: Storagename2
  location: location
  sku: {
    name: StorageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: storageAccesTier
    minimumTlsVersion: 'TLS1_2'
  }

}
resource storageAccount3 'Microsoft.Storage/storageAccounts@2023-01-01' ={
  name: Storagename3
  location: location
  sku: {
    name: StorageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: storageAccesTier
    minimumTlsVersion: 'TLS1_2'
  }

}

// Crear servicio de tabla en la cuenta de almacenamiento
resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2021-08-01' = {
  parent: storageAccount
  name: 'default'
}

// Crear tabla en el servicio de tabla
resource storageTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-08-01' = {
  parent: tableService
  name: tablename
}

// Crear servicio de blob container en la cuenta de almacenamiento
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}
// Crear blob container en el servicio de tabla
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = [for containerName in containerNames: {
  parent: blobService
  name: !empty(containerNames) ? '${toLower(containerName)}' : 'placeholder'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}]

var storageId2 =listKeys(storageAccount2.id, '2021-09-01').keys[0].value

output storageName string= storageAccount.name
output storageName2 string= storageAccount2.name
output storageName3 string = storageAccount3.name

output storageId2 string= storageId2
