param location string
param env string
param cliente string
param sqlSkuName string
param sqlTier string
@secure()
param admidPasswordDB string
var sqlServerName= 'sqlserver-${cliente}-${env}'
param admidUsernameDB string

var nombredeBD = [
  '${cliente}-repext-${env}'
  'plcolab-notification-${cliente}-${env}'
]


resource sqlServer 'Microsoft.Sql/servers@2021-11-01'= {
  name: sqlServerName
  location: location
  properties:{
    administratorLogin: admidUsernameDB
    administratorLoginPassword: admidPasswordDB
  }
  }


resource sqlDB2 'Microsoft.Sql/servers/databases@2021-11-01' = [for name in nombredeBD : {
    parent: sqlServer
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
output serverName string= sqlServer.name
