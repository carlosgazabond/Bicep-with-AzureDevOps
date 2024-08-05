param location string= resourceGroup().location
param appServiceSku string = 'B1'
param cliente string
param appServiceLinuxVersion string
param env string
@allowed([
  'windows'
  'linux'
])
param appServiceOS string 
param appServiceWindowsVersion string

var appserviceOS = (appServiceOS == 'windows') ? false: true
var appServicePlanApi = 'plcolab-api-${cliente}-${env}'
var appServicePlanValidating = 'plcolab-validating-${cliente}-${env}'
var appServiceApiName= 'plcolab-api-${cliente}-${env}'
var appServiceAsyncName= 'plcolab-async-${cliente}-${env}'
var appServiceValidatingName= 'plcolab-validating-${cliente}-${env}'
var appServicePlanNotification= 'plcolab-notification-webjobs-${cliente}-${env}'
var appServiceNotification= 'plcolab-notification-webjobs-${cliente}-${env}'

param storageaccountApiName string
param storageaccountNotificadorName string
param storageaccountRepextName string

//App settings existentes
param currentAppSettings object
param currentAppSettingsWebJobs object
param currentAppSettingsValidating object

//App settings nuevos
param additionalAppSettingsApi object = {}
param additionalAppSettingsValidating object = {}
param additionalAppSettingsWebJobs object = {}

var asyncSettings = {
  'PLColab.Api.Url': 'https://plcolab-api-${cliente}-${env}.azurewebsites.net'
}

//Connection String existentes
param currentConnecStringsApi object = {}
param currentConnecStringsValidating object
param currentConnecStringsWebJobs object

var additionalConnStringsApi = {
  'EmisionBajaLatencia.Storage.ConnectionString.ConciliarEmisionesEnValidatingCommands': {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
  'Notification.Storage': {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount2.name};AccountKey=${storageAccount2.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
  '${cliente}.RepExt.Storage': {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount3.name};AccountKey=${storageAccount3.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
}

var additionalConnStringsValidating  ={
  'EmisionBajaLatencia.Storage.ConnectionString.ConciliarEmisionesEnValidatingCommands': {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
  'Notification.Storage': {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount2.name};AccountKey=${storageAccount2.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
  '${cliente}.RepExt.Storage': {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount3.name};AccountKey=${storageAccount3.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
}
var additionalConnStringsWebJobs  = {
  AzureWebJobsDashboard: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount2.name};AccountKey=${storageAccount2.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
  'Notification.Storage': {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount2.name};AccountKey=${storageAccount2.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
  
}


resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01'= {
  name: appServicePlanApi
  location: location
  sku:{
    name: appServiceSku
  }
  properties: {
    reserved: appserviceOS
  }
  kind: appServiceOS

}

resource appServicePlan2 'Microsoft.Web/serverfarms@2023-01-01'= {
  name: appServicePlanValidating
  location: location
  sku:{
    name: appServiceSku
  }
  properties: {
    reserved: appserviceOS
  }
  kind: appServiceOS

}

resource appServicePlan3 'Microsoft.Web/serverfarms@2023-01-01'= {
  name: appServicePlanNotification
  location: location
  sku:{
    name: appServiceSku
  }
  properties: {
    reserved: appserviceOS
  }
  kind: appServiceOS

}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing ={
  name: storageaccountApiName

}

resource storageAccount2 'Microsoft.Storage/storageAccounts@2022-09-01' existing ={
  name: storageaccountNotificadorName

}

resource storageAccount3 'Microsoft.Storage/storageAccounts@2022-09-01' existing={
  name: storageaccountRepextName

}

resource appServiceApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceApiName
  location: location
  tags: {
    name: 'final'
  }
  properties:{
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    
    siteConfig: {
      linuxFxVersion:appServiceLinuxVersion
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
      alwaysOn: true
      appSettings: []

      connectionStrings: []
    }
    }

    resource webConfig 'config' = {
      name: 'web'
      properties: {
        netFrameworkVersion: appServiceWindowsVersion
        metadata: [
          {
            name: 'CURRENT_STACK'
            value: 'dotnet'
          }
        ]
      }
    }

}

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceApp
  name: 'appsettings'
  properties: union(currentAppSettings, additionalAppSettingsApi)
}

resource siteconfig2 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceAsync
  name: 'appsettings'
  properties: union(currentAppSettings, additionalAppSettingsApi, asyncSettings)
}

resource siteconfig3 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceValidating
  name: 'appsettings'
  properties: union(currentAppSettingsValidating, additionalAppSettingsValidating)
}

resource siteconfig4 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceWebJobs
  name: 'appsettings'
  properties: union(currentAppSettingsWebJobs, additionalAppSettingsWebJobs)
}

resource siteconfig5 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceApp
  name: 'connectionstrings'
  properties: union(currentConnecStringsApi, additionalConnStringsApi)
}

resource siteconfig6 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceAsync
  name: 'connectionstrings'
  properties: union(currentConnecStringsApi, additionalConnStringsApi)
}

resource siteconfig7 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceValidating
  name: 'connectionstrings'
  properties: union(currentConnecStringsValidating, additionalConnStringsValidating)
}

resource siteconfig8 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceWebJobs
  name: 'connectionstrings'
  properties: union(currentConnecStringsWebJobs, additionalConnStringsWebJobs)
}


resource appServiceAsync 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceAsyncName
  location: location
  properties:{
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    
    siteConfig: {
      virtualApplications: [
        { 
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: false
        }
        { 
          virtualPath: '/queuedissueextendedtenant'
          physicalPath: 'site\\wwwroot\\App_Data\\jobs\\continuous\\QueuedIssueExtendedTenant'
          preloadEnabled: false
        }
        
      ]
      linuxFxVersion:appServiceLinuxVersion
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
      alwaysOn: true
      appSettings: []

      connectionStrings: []
    }
    }

    resource webConfig 'config' = {
      name: 'web'
      properties: {
        netFrameworkVersion: appServiceWindowsVersion
        metadata: [
          {
            name: 'CURRENT_STACK'
            value: 'dotnet'
          }
        ]
      }
    }

}

resource appServiceValidating 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceValidatingName
  location: location
  properties:{
    serverFarmId: appServicePlan2.id
    httpsOnly: true
    clientAffinityEnabled: false
    
    siteConfig: {
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: false
        }
        { 
          virtualPath: '/validatingbajalatenciaP0'
          physicalPath: 'site\\wwwroot\\App_Data\\jobs\\triggered\\ValidatingBajaLatenciaP0'
          preloadEnabled: false
        }
       { 
          virtualPath: '/validatingbajalatenciaP1'
          physicalPath: 'site\\wwwroot\\App_Data\\jobs\\triggered\\ValidatingBajaLatenciaP1'
          preloadEnabled: false
        }

      ]

      linuxFxVersion:appServiceLinuxVersion
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
      alwaysOn: true
      appSettings: []

      connectionStrings: []
    }
    }

    resource webConfig 'config' = {
      name: 'web'
      properties: {
        netFrameworkVersion: appServiceWindowsVersion
        metadata: [
          {
            name: 'CURRENT_STACK'
            value: 'dotnet'
          }
        ]
      }
    }

}

resource appServiceWebJobs 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceNotification
  location: location
  properties:{
    serverFarmId: appServicePlan3.id
    httpsOnly: true
    clientAffinityEnabled: false
    
    siteConfig: {
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: false
        }
        { 
          virtualPath: '/bulkupdater'
          physicalPath: 'site\\wwwroot\\App_Data\\jobs\\continuous\\BulkUpdateRetryRunOnSchedule'
          preloadEnabled: false
        }
      ]
      linuxFxVersion:appServiceLinuxVersion
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
      alwaysOn: true
      appSettings: []

      connectionStrings: []
    }
    }

    resource webConfig 'config' = {
      name: 'web'
      properties: {
        netFrameworkVersion: appServiceWindowsVersion
        metadata: [
          {
            name: 'CURRENT_STACK'
            value: 'dotnet'
          }
        ]
      }
    }

}



output planNameapp string = appServicePlan.name


