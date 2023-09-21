@minLength(1)
@maxLength(63)
@description('Name of the Key Vault')
param keyVaultName string

@description('Azure location for the resource')
param keyVaultLocation string = resourceGroup().location

var resourceTags  = { 
  'environment': '${clientTag}',
  'client': '${environmentTag}',
  'displayname': '${displayNameTag}'
}


resource keyvault 'Microsoft.KeyVault/vaults@2022-11-01-preview' = {
  name: keyVaultName
  location: keyvaultLocation
  tags: resourceTags
}
