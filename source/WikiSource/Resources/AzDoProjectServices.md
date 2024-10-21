# DSC AzDoProjectServices Resource

## Syntax

```PowerShell
AzDoProjectServices [string] #ResourceName
{
    ProjectName = [String]$ProjectName
    [ GitRepositories = [String]$GitRepositories { 'Enabled' | 'Disabled' } ]
    [ WorkBoards = [String]$WorkBoards { 'Enabled' | 'Disabled' } ]
    [ BuildPipelines = [String]$BuildPipelines { 'Enabled' | 'Disabled' } ]
    [ TestPlans = [String]$TestPlans { 'Enabled' | 'Disabled' } ]
    [ AzureArtifact = [String]$AzureArtifact { 'Enabled' | 'Disabled' } ]
}
```

## Properties

### Common Properties

- **ProjectName**: The name of the Azure DevOps project. This property is mandatory and serves as the key property for the resource.
- **GitRepositories**: Specifies whether Git repositories are enabled or disabled. Valid values are `Enabled` or `Disabled`. Default is `Enabled`.
- **WorkBoards**: Specifies whether work boards are enabled or disabled. Valid values are `Enabled` or `Disabled`. Default is `Enabled`.
- **BuildPipelines**: Specifies whether build pipelines are enabled or disabled. Valid values are `Enabled` or `Disabled`. Default is `Enabled`.
- **TestPlans**: Specifies whether test plans are enabled or disabled. Valid values are `Enabled` or `Disabled`. Default is `Enabled`.
- **AzureArtifact**: Specifies whether Azure artifacts are enabled or disabled. Valid values are `Enabled` or `Disabled`. Default is `Enabled`.

## Additional Information

This resource is used to manage Azure DevOps project services using Desired State Configuration (DSC). It allows you to define the properties of an Azure DevOps project and ensures that the services are configured according to those properties.

## Examples

### Example 1: Sample Configuration using AzDoProjectServices Resource

```PowerShell
Configuration ExampleConfig {
    Import-DscResource -ModuleName 'AzDevOpsDsc'

    Node localhost {
        AzDoProjectServices ProjectServices {
            Ensure             = 'Present'
            ProjectName        = 'SampleProject'
            GitRepositories    = 'Enabled'
            WorkBoards         = 'Enabled'
            BuildPipelines     = 'Enabled'
            TestPlans          = 'Enabled'
            AzureArtifact      = 'Enabled'
        }
    }
}

ExampleConfig
Start-DscConfiguration -Path ./ExampleConfig -Wait -Verbose
```

### Example 2: Sample Configuration using Invoke-DSCResource

```PowerShell
# Return the current configuration for AzDoProjectServices
# Ensure is not required
$properties = @{
    ProjectName      = 'SampleProject'
    GitRepositories  = 'Enabled'
    WorkBoards       = 'Enabled'
    BuildPipelines   = 'Enabled'
    TestPlans        = 'Enabled'
    AzureArtifact    = 'Enabled'
}

Invoke-DSCResource -Name 'AzDoProjectServices' -Method Get -Property $properties -ModuleName 'AzureDevOpsDsc'
```

### Example 3: Sample Configuration using AzDO-DSC-LCM

```YAML
parameters: {}

variables: {
   "PlaceHolder2": "PlaceHolder"  
}

resources:
- name: Sample Project Services
  type: AzureDevOpsDsc/AzDoProjectServices
  properties:
    ProjectName: SampleProject
    GitRepositories: Enabled
    WorkBoards: Enabled
    BuildPipelines: Enabled
    TestPlans: Enabled
    AzureArtifact: Enabled
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

