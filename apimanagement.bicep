param publisherEmail string
@minLength(1)
param publisherName string
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'
@allowed([
  0
  1
  2
])
param skuCount int = 1
param env string
param cliente string
param location string = resourceGroup().location
var apiManagementName = 'plcolab-apim-${cliente}-${env}'
var plcolab = '[plcolab-'
param suscripcion string =subscription().subscriptionId
param rgName string

resource apiManagementService 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apiManagementName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

resource apiManagementProduct2 'Microsoft.ApiManagement/service/products@2022-08-01'={
  parent: apiManagementService
  name: 'apimanagement2'
  properties: {
      
      displayName: '${plcolab}${env}] Anonymous'
      state: 'published'
      approvalRequired: false
      description: 'Api for UA admin tasks'
    
    }

}

resource apiManagementProduct3 'Microsoft.ApiManagement/service/products@2022-08-01'={
  parent: apiManagementService
  name: 'apimanagement3'
  properties: {
      
      displayName: '${plcolab}${env}] billforce'
      state: 'published'
      subscriptionRequired: true
      approvalRequired: false
      description: '[plcolab-qa] billforce'
    
    }

}

resource apiManagementProduct4 'Microsoft.ApiManagement/service/products@2022-08-01'={
  parent: apiManagementService
  name: 'apimanagement4'
  properties: {
      
      displayName: '${plcolab}${env}] Emisión'
      state: 'published'
      subscriptionRequired: true
      approvalRequired: false
      description: 'Document issue Apis related'
    
    }

}

resource apiManagementProduct5 'Microsoft.ApiManagement/service/products@2022-08-01'={
  parent: apiManagementService
  name: 'apimanagement5'
  properties: {
      
      displayName: '${plcolab}${env}] Mobile Emision'
      state: 'published'
      subscriptionRequired: true
      approvalRequired: true
      description: 'plcolab-qa-mobile-emision'
    
    }

}

resource apiManagementProduct 'Microsoft.ApiManagement/service/products@2022-08-01'={
  parent: apiManagementService
  name: 'apimanagement'
  properties: {
      
      displayName: '${plcolab}${env}] Recepción'
      state: 'published'
      subscriptionRequired: true
      approvalRequired: false
      description: 'Document reception apis related'
      
    }


}

resource roleAssignment 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  name: 'roleassigment'
  parent: apiManagementProduct
  properties: {
    
    groupId: '/subscriptions/${suscripcion}/resourceGroups/${rgName}${env}/providers/Microsoft.ApiManagement/service/${apiManagementName}/groups/developers'
  }
  
}

resource roleAssignment2 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  name: 'roleassigment2'
  parent: apiManagementProduct2
  properties: {
    
    groupId: '/subscriptions/${suscripcion}/resourceGroups/${rgName}${env}/providers/Microsoft.ApiManagement/service/${apiManagementName}/groups/developers'
  }
  
}
resource roleAssignment3 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  name: 'roleassigment3'
  parent: apiManagementProduct3
  properties: {
    
    groupId: '/subscriptions/${suscripcion}/resourceGroups/${rgName}${env}/providers/Microsoft.ApiManagement/service/${apiManagementName}/groups/developers'
  }
  
}

resource roleAssignment4 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  name: 'roleassigment4'
  parent: apiManagementProduct4
  properties: {
    
    groupId: '/subscriptions/${suscripcion}/resourceGroups/${rgName}${env}/providers/Microsoft.ApiManagement/service/${apiManagementName}/groups/developers'
  }
  
}

resource roleAssignment5 'Microsoft.ApiManagement/service/products/groupLinks@2023-05-01-preview' = {
  name: 'roleassigment5'
  parent: apiManagementProduct5
  properties: {
    
    groupId: '/subscriptions/${suscripcion}/resourceGroups/${rgName}${env}/providers/Microsoft.ApiManagement/service/${apiManagementName}/groups/developers'
  }
  
}



output apimName string= apiManagementService.name


resource namedValue2 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementService
  name: 'PorcentajePeticionesUrlMicroLogin'
  properties: {
    displayName: 'PorcentajePeticionesUrlMicroLogin'
    value: '100'
    secret: false
  }
}

resource namedValue3 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementService
  name: 'UrlLoginApiMicroLogin'
  properties: {
    displayName: 'UrlLoginApiMicroLogin'
    value: 'https://pl-micrologin-qa.thankfulocean-de4fd1e3.eastus2.azurecontainerapps.io/Auth'
    secret: false
  }
}

resource namedValue4 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apiManagementService
  name: 'UrlLoginApiMonolito'
  properties: {
    displayName: 'UrlLoginApiMonolito'
    value: 'https://plcolab-api-2qa.facture.co/JwtAuth/Registration'
    secret: false
  }
}

