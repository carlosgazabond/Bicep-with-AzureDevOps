@description('The name of the function app that you wish to create.')
param storageAccountNotificadorName string
param appServicePlanSku string = 'Y1'
param tierFunction string = 'Dynamic'
param functionWindowsVersion string
param cliente string
param env string
@description('Location for all resources.')
param location string = resourceGroup().location
@description('The language worker runtime to load in the function app.')

var hostingPlanName = 'notification-plan-${cliente}-${env}'
var functionAppName = 'plcolab-notification-${cliente}-${env}'
param Guid string = newGuid()
param currentConnecStringsFunction object = {}

param currentAppSettingsFunction object
var additionalAppSettingsFunction ={

  WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
 
  FUNCTIONS_EXTENSION_VERSION:'~1'

  'Url.ApiRoot.Jobs': 'https://plcolab-api-${cliente}-${env}.azurewebsites.net'
  
  AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  
  AzureWebJobsDashboard: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
 
  'AzureWebJobs.EndpointAppServiceSettings.Disabled':'1'
  
 
  'AzureWebJobs.EndpointEmailValidation.Disabled':'1'
  
 
  'AzureWebJobs.EndpointInboundEmailAmazonSES.Disabled':'1'
  
 
  'AzureWebJobs.EndpointServicePointMonitor.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderDian_Low.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderDian.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderDianCheckStatus_Low.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderDianCheckStatus.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderEmail_High.Disabled' :'1'
  
 
  'AzureWebJobs.QueueSenderEmail_Low.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderEmail.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderEmailFunction_High.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderEmailFunction_Low.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderFTPIssue.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderInboundEmail.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderInboundEmailAction.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderInterop.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderInteropCheckStatus.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderInteropReceive.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderIssue.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderIssueProforma.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderIssueProformaBulk.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderPLColabApi_Low.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderRest.Disabled':'1'
  
 
  'AzureWebJobs.QueueSenderSms.Disabled':'1'
  
 
  'AzureWebJobs.TimerKeepAlive.Disabled':'1'
  
 
  'App.AnonymousMasterKey':Guid
  
  'SingleTenant.Api.Url': 'https://plcolab-api-${cliente}-${env}.azurewebsites.net'

}

var additionalConnectionStringFunction = {
  'Notification.Storage': {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
  AzureWebJobsDashboard: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    type: 'Custom'
  }
}


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountNotificadorName
  
}


resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: appServicePlanSku
    tier: tierFunction
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      use32BitWorkerProcess: false
      functionAppScaleLimit: 1 
      appSettings: []
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      netFrameworkVersion: functionWindowsVersion
    }
    httpsOnly: true
  }
}

output functionAppname string= functionApp.name
output guid string = Guid

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: union(currentAppSettingsFunction, additionalAppSettingsFunction)
}

resource siteconfig6 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: functionApp
  name: 'connectionstrings'
  properties: union(currentConnecStringsFunction, additionalConnectionStringFunction)
}
