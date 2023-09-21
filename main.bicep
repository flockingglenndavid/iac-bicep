targetScope = 'subscription'



@minLength(2)
@maxLength(5)
@description('2-4 chars to prefix the Azure resources, NOTE: no number or symbols')
param prefix string = 'flock'


@minLength(3)
@maxLength(20)
@description('Client name, 3-20 chars NOTE: no spaces, number or symbols')
param clientName string = 'client'


@description('Azure location for the resourcs')
param resourceLocation string = 'australiaeast'

param client string
param environment string


//common variables
var uniqueSubString = uniqueString(guid(subscription().subscriptionId)) // used to create unique resources names
var uString = '${prefix}${replace(replace(replace(clientName,'-',''),'_',''),' ','')}${uniqueSubString}' // used for resource names

// resource names
var resourceGroupName = '${prefix}-${toLower(clientName)}-rg'
var sqlServerName = '${prefix}-${toLower(clientName)}-sql'
var keyVaultName = '${prefix}-${toLower(clientName)}-kv'
var storageAccountName = '${toLower(substring(uString, 0, 14))}store01'

// key vault variables
var deploymentKeyVaultName  = 'DeploymentSecrets${uniqueSubString}'





//create resource group

resource rg './modules/common/resource.group.bicep' = {
  params: {
    resourceGroupName: resourceGroupName
    resourceGroupLocation: resourceLocation
    clientTag: client
    environmentTag: environment
    displayNameTag: 'Resource Group'

  }
}


//create key vault to hold any generated logins and passwords
resource dkv './modules/common/keyvault.tempate.bicep'  = {
  scope: rg
  params: {
    keyVaultName: deploymentKeyVaultName
    clientTag: client
    environmentTag: environment
    displayNameTag: 'Deployment Key Vault'
  }
}


//create SQL Server


var keyvaultSecretLogin = 'serveradmin'
@secure() //Prevents it from being logged, but also removes it from output
var keyvaultSecretPasssword = newGuid() //Can only be used as the default value for a param

resource sqlserver './modules/databases/sql.server.template.bicep' = {
  scope: rg
  params: {
    serverName: sqlServerName
    clientTag: client
    environmentTag: environment
    displayNameTag: 'SQL Server'
  }
  
}


resource KVSecretLogin 'Microsoft.KeyVault/vaults/secrets@2022-11-01-preview' = {
  name: 'SQLAdminLoginName'
  parent: dkv
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: keyvaultSecretLogin
  }
}

resource KVSecretPassword 'Microsoft.KeyVault/vaults/secrets@2022-11-01-preview' = {
  name: 'SQLAdminPasword'
  parent: dkv
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: keyvaultSecretPasssword
  }
}

//output SQLServerAdminLogin string = KVSecretLogin.properties.secretUri
//output SQLServerAdminPassword string = KVSecretPassword.properties.secretUri
