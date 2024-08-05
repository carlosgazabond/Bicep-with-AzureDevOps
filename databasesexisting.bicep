param location string
param env string
param cliente string
param sqlSkuName string
param sqlTier string
@secure()
param sqlServerNameExisting string
var nombredeBD = [
  '${cliente}-repext-${env}'
  'plcolab-notification-${cliente}-${env}'
]


// Declaración del servidor SQL existente
resource sqlServerExisting 'Microsoft.Sql/servers@2021-11-01' existing =  {
  name: sqlServerNameExisting
}

// Bases de datos para el servidor SQL existente
resource sqlDB 'Microsoft.Sql/servers/databases@2021-11-01' = [for name in nombredeBD : {
  parent: sqlServerExisting
  name: name
  location: location
  sku: {
    name: sqlSkuName
    tier: sqlTier
  }
  properties: {
    collation: 'Modern_Spanish_CI_AI'
  }
}]
