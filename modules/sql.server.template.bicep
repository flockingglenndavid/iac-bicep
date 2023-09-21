@minLength(1)
@maxLength(63)
@description('Name of the SQL Server')
param serverName string

@description('Azure location for the resource')
param serverLocation string = resourceGroup().location

param clientTag string
param environmentTag string
param displayNameTag string

var resourceTags  = { 
    'environment': '${clientTag}',
    'client': '${environmentTag}',
    'displayname': '${displayNameTag}'
}

@allowed([
  'None'
  'SystemAssigned'
  'UserAssigned'
  'UserAssigned'
])
@description('The identity type. Default is SystemAssigned.')
param identityType string = 'SystemAssigned'


resource sqlserver 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: serverName
  location: serverLocation
  tags: resourceTags
  identity: {
    type: identityType
    userAssignedIdentities: {}
  }
  properties: {
    administratorLogin: 'string'
    administratorLoginPassword: 'string'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: bool
      login: 'string'
      principalType: 'string'
      sid: 'string'
      tenantId: 'string'
    }
    federatedClientId: 'string'
    keyId: 'string'
    minimalTlsVersion: 'string'
    primaryUserAssignedIdentityId: 'string'
    publicNetworkAccess: 'string'
    restrictOutboundNetworkAccess: 'string'
    version: 'string'
  }
}



