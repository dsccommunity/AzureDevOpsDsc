# DSC xAzDoProjectGroup Resource

## Syntax

```PowerShell
xAzDoProjectGroup [string] #ResourceName
{
    GroupName = [String]$GroupName
    ProjectName = [String]$ProjectName
    [ GroupDescription = [String]$GroupDescription ]
}
```

## Properties

### Common Properties

- **GroupName**: The name of the project group. This property is mandatory and serves as the key property for the resource.
- **ProjectName**: The name of the Azure DevOps project associated with this group. This property is mandatory.
- **GroupDescription**: A description of the project group.

## Additional Information

This resource is used to manage Azure DevOps project groups using Desired State Configuration (DSC). It allows you to define the properties of an Azure DevOps project group and ensures that the group is configured according to those properties.

## Examples

### Example 1: Sample Configuration using xAzDoProjectGroup Resource

```PowerShell
Configuration ExampleConfig {
    Import-DscResource -ModuleName 'AzDevOpsDsc'

    Node localhost {
        xAzDoProjectGroup ProjectGroup {
            Ensure              = 'Present'
            GroupName           = 'SampleProjectGroup'
            ProjectName         = 'SampleProject'
            GroupDescription    = 'This is a sample project group!'
        }
    }
}

ExampleConfig
Start-DscConfiguration -Path ./ExampleConfig -Wait -Verbose
```

### Example 2: Sample Configuration using Invoke-DSCResource

```PowerShell
# Return the current configuration for xAzDoProjectGroup
# Ensure is not required
$properties = @{
    GroupName = 'SampleProjectGroup'
    ProjectName = 'SampleProject'
    GroupDescription = 'This is a sample project group!'
}

Invoke-DSCResource -Name 'xAzDoProjectGroup' -Method Get -Property $properties -ModuleName 'AzureDevOpsDsc'
```

### Example 3: Sample Configuration using xAzDoDSCDatum

```YAML
parameters: {}

variables: {
   "PlaceHolder2": "PlaceHolder"  
}

resources:
- name: Team Leaders Project Group
  type: AzureDevOpsDsc/xAzDoProjectGroup
  properties:
    GroupName: AZDO_TeamLeaders_ProjectGroup
    ProjectName: SampleProject
    GroupDescription: Team Leaders Project Group

- name: Service Accounts Project Group
  type: AzureDevOpsDsc/xAzDoProjectGroup
  properties:
    GroupName: AZDO_ServiceAccounts_ProjectGroup
    ProjectName: SampleProject
    GroupDescription: Service Accounts Project Group
```

LCM Initialization:

```PowerShell

$params = @{
    AzureDevopsOrganizationName = "SampleAzDoOrgName"
    ConfigurationDirectory      = "C:\Datum\DSCOutput\"
    ConfigurationUrl            = 'https://configuration-path'
    JITToken                    = 'SampleJITToken'
    Mode                        = 'Set'
    AuthenticationType          = 'ManagedIdentity'
    ReportPath                  = 'C:\Datum\DSCOutput\Reports'
}

.\Invoke-AZDOLCM.ps1 @params
```
