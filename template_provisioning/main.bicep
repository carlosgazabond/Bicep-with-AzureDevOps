param location string= 'eastus2'

//Parametros globales para todos los modulos
param env string
param cliente string

//Parametros de Storage
param storageAccesTier string 
param StorageSku string 

//Parametros del api management
param skuApiManagement string 
param skucountApiManag int
param publisherEmail string
param publisherName string
param rgName string

//Parametros de function App y AppService
param appServiceWindowsVersion string
param appServiceSku string
param appServiceOS string
param appServiceLinuxVersion string
param webAppNameSettings string
param webFunctionAppNameSettings string
param webValidatingSettings string
param webJobsSettings string
param existingRG string

//Parametros de la base de datos de SQL
param databaseSKU string
param sqlTier string
param admidUsernameDB string
@secure()
param admidPasswordDB string
param RgdelServidorBD string
param sqlServerNameExisting string


//Variables para obtener lista de los app setttings
var currentAppSettingsApi = list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebApp.name, 'appsettings'), '2023-12-01').properties
var currentAppSettingsValidating= list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebApp2.name, 'appsettings'), '2023-12-01').properties
var currentAppSettingsWebJobs = list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebApp3.name, 'appsettings'), '2023-12-01').properties

//Variables para obtener los connection strings
var currentConnecStringsApi = list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebApp.name, 'connectionstrings'), '2023-12-01').properties
var currentConnecStringsValidating = list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebApp2.name, 'connectionstrings'), '2023-12-01').properties
var currentConnecStringsWebJobs= list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebApp3.name, 'connectionstrings'), '2023-12-01').properties

//Variables para obtener app settings function
var currentAppSettingsFunction = list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebFunctionApp.name, 'appsettings'), '2023-12-01').properties

//Variables para obtener connection strings function
var currentConnecStringsFunction = list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebFunctionApp.name, 'connectionstrings'), '2023-12-01').properties

var appServicePlanApi = 'plcolab-api-${cliente}-${env}'



module storage 'storages.bicep'={
  name: 'functionAppStorage'
  params: {
    env: env //Opciones: 'qa', 'beta', 'pro'
    cliente: cliente
    location: location
    //*IMPORTANTE* TODA INFORMACION INGRESADA DEBE SER DENTRO LAS COMILLAS ''
    storageAccesTier: storageAccesTier //Ingresa el accessTier del storage
    StorageSku: StorageSku //Ingresa el Sku del storage (Produccion se usa: 'Standard_LRS')
  }
}

module apiManagement 'apimanagement.bicep' ={
  name: 'apimanagement'
  params: {
    env: env
    cliente: cliente
    publisherEmail: publisherEmail //Correo electronico del owner del servicio
    publisherName: publisherName //El nombbre del owner del servicio
    sku: skuApiManagement //Plan api management, Opciones: Consumption, Developer, Basic, Standar, Premium
    skuCount: skucountApiManag //Contador del sku, opciones: 1, 2, 3
    location: location 
    rgName: rgName
  }
}

module lambdaFunction 'functions.bicep' ={
  name: 'function'
  params: {
    env: env
    cliente: cliente
    functionWindowsVersion: appServiceWindowsVersion //Opciones: v.4.8, v6.0, v7.0, v8.0
    location: location
    storageAccountNotificadorName: storage.outputs.storageName2 //Nombre del nuevo storage
    currentAppSettingsFunction: currentAppSettingsFunction
    currentConnecStringsFunction: currentConnecStringsFunction
  }
}

module AppServices 'appservices.bicep' ={
  name: 'AppService'
  params: {
    location: location
    //*IMPORTANTE* TODA INFORMACION INGRESADA DEBE SER DENTRO LAS COMILLAS ''
    appServiceOS: appServiceOS //Ingrese el OS ''linux, windows''
    env: env //Opciones: 'qa', 'beta', 'pro'
    storageaccountApiName: storage.outputs.storageName
    storageaccountNotificadorName: storage.outputs.storageName2
    storageaccountRepextName: storage.outputs.storageName3
    appServiceLinuxVersion: appServiceLinuxVersion //*RELLENAR SOLO SI ES LINUX SI NO DEJAR VACIA LAS COMILLAS* Ingrese la version de su API LINUX: 'DOTNETCORE|6.0', 'ASPNET|V4.8'
    appServiceWindowsVersion: appServiceWindowsVersion  //*RELLENAR SOLO SI ES WINDOWS SI NO DEJAR VACIA LAS COMILLAS* Ingrese el numero de version 'v7.0' 'v6.0'
    cliente: cliente //Ingresa el nombre del plan de la ap
    appServiceSku: appServiceSku //Ingresa el tipo de Sku que deseas para el appservice, por default es B1
    currentAppSettings: currentAppSettingsApi
    currentAppSettingsValidating: currentAppSettingsValidating
    currentAppSettingsWebJobs: currentAppSettingsWebJobs
    additionalAppSettingsApi: {
      // Añade aquí los nuevos settings que quieras añadir o sobrescribir
      'Notification.SiteName': lambdaFunction.outputs.functionAppname
      'App.AnonymousMasterKey': lambdaFunction.outputs.guid
      'PLColab.API.ApiManagement.GatewayUrl': 'https://${apiManagement.outputs.apimName}.azure-api.net'
      'Url.ApiRoot': 'https://${appServicePlanApi}.azurewebsites.net'
      'ApiSite.Pdf.Url': 'https://${appServicePlanApi}.azurewebsites.net'

    }
    additionalAppSettingsValidating:{
      'Notification.SiteName': lambdaFunction.outputs.functionAppname
      'App.AnonymousMasterKey': lambdaFunction.outputs.guid
      'PLColab.API.ApiManagement.GatewayUrl': 'https://${apiManagement.outputs.apimName}.azure-api.net'
      'Url.ApiRoot': 'https://${appServicePlanApi}.azurewebsites.net'
      'ApiSite.Pdf.Url': 'https://${appServicePlanApi}.azurewebsites.net'
      
    }
    additionalAppSettingsWebJobs:{
      'Notification.SiteName': lambdaFunction.outputs.functionAppname
      AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storage.outputs.storageName2};AccountKey=${storage.outputs.storageId2};EndpointSuffix=${environment().suffixes.storage}'
    }
    
    currentConnecStringsApi: currentConnecStringsApi
    currentConnecStringsValidating: currentConnecStringsValidating
    currentConnecStringsWebJobs: currentConnecStringsWebJobs
    }
  }


module sqlServer 'databases.bicep'=if((empty(sqlServerNameExisting))){
  name: 'sqlServer'
  scope: resourceGroup(rgName)
  params: {
    location: location
    env: env
    cliente: cliente
    sqlSkuName: databaseSKU
    sqlTier: sqlTier
    admidPasswordDB: admidPasswordDB
    admidUsernameDB: admidUsernameDB
  }
} 

module sqlServerExisting 'databasesexisting.bicep'= if((!empty(sqlServerNameExisting))){
  name: 'sqlServerExisting'
  scope: resourceGroup(RgdelServidorBD)
  params: {
    location: location
    env: env
    cliente: cliente
    sqlSkuName: databaseSKU
    sqlTier: sqlTier
    sqlServerNameExisting: sqlServerNameExisting
  }
} 




resource existingWebApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppNameSettings
  scope: resourceGroup(existingRG)
}

resource existingWebApp2 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webValidatingSettings
  scope: resourceGroup(existingRG)
}

resource existingWebApp3 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webJobsSettings
  scope: resourceGroup(existingRG)
}

resource existingWebFunctionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webFunctionAppNameSettings
  scope: resourceGroup(existingRG)
}

