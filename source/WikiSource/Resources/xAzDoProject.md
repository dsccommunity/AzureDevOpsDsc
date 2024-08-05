# DSC xAzDoProject Resource

# Syntax

``` PowerShell
xAzDoProject [string] #ResourceName
{
    ProjectName = [String]$ProjectName
    [ Ensure = [String] {'Present', 'Absent'}]
    [ ProjectDescription = [String]$ProjectDescription]
    [ SourceControlType = [String] {'Git', 'Tfvc'}]
    [ ProcessTemplate = [String] {'Agile', 'Scrum', 'CMMI', 'Basic'}]
    [ Visibility = [String] {'Public', 'Private'}]
}
```

# Properties

Common Properties:

- _ProjectName_: The name of the Azure DevOps project.
- _ProjectDescription_: A description for the Azure DevOps project.
- _SourceControlType_: The type of source control (Git or Tfvc). Default is Git.
- _ProcessTemplate_: The process template to use (Agile, Scrum, CMMI, Basic). Default is Agile.
- _Visibility_: The visibility of the project (Public or Private). Default is Private.

# Additional Information

This resource is used to manage Azure DevOps projects using Desired State Configuration (DSC).
It allows you to define the properties of an Azure DevOps project and ensures that the project is configured according to those properties.

# Example

__Sample Configuration for Azure DevOps Project using xAzDoProject Resource__

``` PowerShell
Configuration ExampleConfig {
    Import-DscResource -ModuleName 'AzDevOpsDsc'

    Node localhost {
        xAzDoProject ProjectExample {
            Ensure             = 'Present'
            ProjectName        = 'MySampleProject'
            ProjectDescription = 'This is a sample Azure DevOps project.'
            SourceControlType  = 'Git'
            ProcessTemplate    = 'Agile'
            Visibility         = 'Private'
        }
    }
}

ExampleConfig
Start-DscConfiguration -Path ./ExampleConfig -Wait -Verbose

```

__Sample Configuration for Azure DevOps Project using Invoke-DSCResource__

``` PowerShell
# Return the current configuration for xAzDoProject
# Ensure is not required
$properties = @{
    ProjectName             = 'MySameProject'
    ProjectDiscription      = 'This is a sample Azure DevOps project'
    SourceControlType       = 'Git'
    ProcessTemplate         = 'Agile'
    Visibility              = 'Private'
}

Invoke-DSCResource -Name 'xAzDoProject' -Method Get -Property $properties -ModuleName 'AzureDevOpsDsc'
```

__Sample Configuration to remove/exclude an Azure DevOps Project using Invoke-DSCResource__

``` PowerShell
# Remove the Azure Devops Project and ensure that it is not recreated.
$properties = @{
    ProjectName             = 'MySameProject'
    Ensure                  = 'Absent'
}

Invoke-DSCResource -Name 'xAzDoProject' -Method Set -Property $properties -ModuleName 'AzureDevOpsDsc'
```

__Sample Configuration using xAzDoDSCDatum__

``` YAML
parameters: {}

variables: {
  ProjectName: SampleProject,
  ProjectDescription: This is a SampleProject!   
}

resources:

  - name: Project
    type: AzureDevOpsDsc/xAzDoProject
    properties:
      projectName: $ProjectName
      projectDescription: $ProjectDescription
      visibility: private
      SourceControlType: Git
      ProcessTemplate: Agile
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

.\Invoke-AZDOLCM.ps1 @params

```
