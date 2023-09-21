@minLength(1)
@maxLength(63)
@description('Name of the resource group')
param resourceGroupName string

@description('Default location of the resources')
param resourceGrouplocation string = 'australiaeast'

param clientTag string
param environmentTag string
param displayNameTag string

var resourceTags  = { 
    'environment': '${clientTag}',
    'client': '${environmentTag}',
    'displayname': '${displayNameTag}'
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: resourceGrouplocation
  tags: resourceTags
}
