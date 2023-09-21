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


param username string = 'serveradmin'

@secure() //Prevents it from being logged, but also removes it from output
param password string = newGuid() //Can only be used as the default value for a param


var uniqueSubString = uniqueString(guid(subscription().subscriptionId))
var keyvaultName  = 'SQLServerAdminPassword${uniqueSubString}'
var keyvaultSecretLogin  = 'ServerAdminLogin'
var keyvaultSecretPasssword  = 'ServerAdminPassword'



resource SQLServer 'Microsoft.Sql/servers@2022-11-01-preview' = {
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



//Save as Key Vault secret
resource KeyVault 'Microsoft.KeyVault/vaults@2022-11-01-preview' existing = {
  name: keyvaultName
}

resource KVSecretLogin 'Microsoft.KeyVault/vaults/secrets@2022-11-01-preview' = {
  name: replace(replace(keyvaultSecretLogin, '.', '-'), ' ', '-')
  parent: KeyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: password
  }
}

resource KVSecretPassword 'Microsoft.KeyVault/vaults/secrets@2022-11-01-preview' = {
  name: replace(replace(keyvaultSecretPasssword, '.', '-'), ' ', '-')
  parent: KeyVault
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: password
  }
}

output PasswordSecretUri string = KVSecretLogin.properties.secretUri
output PasswordSecretUri string = KVSecretPassword.properties.secretUri
