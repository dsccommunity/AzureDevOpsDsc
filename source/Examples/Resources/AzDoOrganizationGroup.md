# DSC AzDoOrganizationGroup Resource

## Syntax

```PowerShell
AzDoOrganizationGroup [string] #ResourceName
{
    GroupName = [String]$GroupName
    [ GroupDescription = [String]$GroupDescription ]
}
```

## Properties

### Common Properties

- **GroupName**: The name of the organization group. This property is mandatory and serves as the key property for the resource.
- **GroupDescription**: A description of the organization group.

## Additional Information

This resource is used to manage Azure DevOps organization groups using Desired State Configuration (DSC). It allows you to define the properties of an Azure DevOps organization group and ensures that the group is configured according to those properties.

## Examples

## Example 1: Sample Configuration using AzDoOrganizationGroup Resource

``` PowerShell
Configuration ExampleConfig {
    Import-DscResource -ModuleName 'AzDevOpsDsc'

    Node localhost {
        AzDoOrganizationGroup OrgGroup {
            Ensure              = 'Present'
            GroupName           = 'SampleGroup'
            GroupDescription    = 'This is a sample group!'
        }
    }
}

OrgGroup
Start-DscConfiguration -Path ./ExampleConfig -Wait -Verbose

```

## Example 2: Sample Configuration using Invoke-DSCResource

``` PowerShell
# Return the current configuration for AzDoGitPermission
# Ensure is not required
$properties = @{
    GroupName = 'SampleGroup'
    GroupDescription = 'This is a sample group!'
}

Invoke-DSCResource -Name 'AzDoOrganizationGroup' -Method Get -Property $properties -ModuleName 'AzureDevOpsDsc'
```

## Example 3: Sample Configuration using AzDO-DSC-LCM

``` YAML
parameters: {}

variables: {
   "PlaceHolder2": "PlaceHolder"  
}

resources:
- name: Team Leaders Organization Group
  type: AzureDevOpsDsc/AzDoOrganizationGroup
  properties:
    GroupName: AZDO_TeamLeaders_Group
    GroupDescription: Team Leaders Organization Group

- name: Service Accounts Organization Group
  type: AzureDevOpsDsc/AzDoOrganizationGroup
  properties:
    GroupName: AZDO_ServiceAccounts_Group
    GroupDescription: Service Accounts Organization Group
```

LCM Initialization:

``` PowerShell

$params = @{
    AzureDevopsOrganizationName = "SampleAzDoOrgName"
    ConfigurationDirectory      = "C:\Datum\DSCOutput\"
    ConfigurationUrl            = 'https://configuration-path'
    JITToken                    = 'SampleJITToken'
    Mode                        = 'Set'
    AuthenticationType          = 'ManagedIdentity'
    ReportPath                  = 'C:\Datum\DSCOutput\Reports'
}

Invoke-AzDoLCM @params
