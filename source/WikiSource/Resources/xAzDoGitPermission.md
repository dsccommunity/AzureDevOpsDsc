# DSC xAzDoGitPermission Resource

# Syntax

``` PowerShell
xAzDoGitPermission [string] #ResourceName
{
    ProjectName = [String]$ProjectName
    RepositoryName = [String]$RepositoryName
    Permissions = [HashTable]$Permissions # See Permissions Syntax
    [ Ensure = [String] {'Present', 'Absent'}]
}
```

## Permissions Syntax

``` PowerShell
xAzDoGitPermission/Permissions
{
    Identity = [String]$Identity # Syntax
    #   SYNTAX:     '[ProjectName | OrganizationName]\ServicePrincipalName, UserPrincipalName, UserDisplayName, GroupDisplayName'
    #   EXAMPLE:    '[TestProject]\UserName@email.com'
    #   EXAMPLE:    '[SampleOrganizationName]\Project Collection Administrators'
    Permission = [Hashtable[]]$Permissions # See 'Permission List"
}
```

## Permission Usage

``` PowerShell
xAzDoGitPermission/Permissions/Permission
{
    PermissionName|PermissionDisplayName = [String]$Name { 'Allow, Deny' }
}

```

## Permission List

> Either 'Name' or 'DisplayName' can be used

| Name      | DisplayName      | Values | Note |
| ------------- | ------------- | - | - |
|Administer  |            Administer   | [ allow, deny ] | Not recommended. |
|GenericRead |            Read         | [ allow, deny ] | |
|GenericContribute |      Contribute | [ allow, deny ] | |
|ForcePush         |      Force push (rewrite history, delete branches and tags) | [ allow, deny ] | |
|CreateBranch      |     Create branch                                          |[ allow, deny ] | |
|CreateTag         |      Create tag                                            | [ allow, deny ] | |
|ManageNote        |      Manage notes                                          | [ allow, deny ] | |
|PolicyExempt      |      Bypass policies when pushing                          | [ allow, deny ] | |
|CreateRepository  |      Create repository                                     | [ allow, deny ] | |
|DeleteRepository  |      Delete or disable repository                          | [ allow, deny ] | |
|RenameRepository  |      Rename repository                                     | [ allow, deny ] | |
|EditPolicies      |      Edit policies                                         | [ allow, deny ] | |
|RemoveOthersLocks |      Remove others' locks                                  | [ allow, deny ] | |
|ManagePermissions |      Manage permissions                                    | [ allow, deny ] | |
|PullRequestContribute |   Contribute to pull requests                          |  [ allow, deny ] | |
|PullRequestBypassPolicy | Bypass policies when completing pull requests        |  [ allow, deny ] | |
|ViewAdvSecAlerts      |  Advanced Security: view alerts                        | [ allow, deny ] | |
|DismissAdvSecAlerts   |  Advanced Security: manage and dismiss alerts          | [ allow, deny ] | |
|ManageAdvSecScanning  |  Advanced Security: manage settings                    | [ allow, deny ] | |

# Common Properties

Ensure: Specifies whether the project should exist. Defaults to 'Absent'.

# Additional Information

This resource allows you to manage Azure DevOps projects using Desired State Configuration (DSC).
It includes properties for specifying the project name, description, source control type, process template, and visibility.

# Examples

## Example 1: Sample Configuration using xAzDoGitPermission Resource

``` PowerShell
Configuration ExampleConfig {
    Import-DscResource -ModuleName 'AzDevOpsDsc'

    Node localhost {
        xAzDoGitPermission GitPermission {
            Ensure             = 'Present'
            ProjectName        = 'SampleProject'
            RepositoryName     = 'SampleGitRepository'
            isInherited        = $true
            Permissions        = @(
                @{
                    Identity = '[ProjectName]\GroupName'
                    Permissions = @{
                        Read = 'Allow'
                        "Manage Notes" = 'Allow'
                        "Contribute" = 'Deny'
                    }
                }
            )
        }
    }
}

ExampleConfig
Start-DscConfiguration -Path ./ExampleConfig -Wait -Verbose

```

## Example 2: Sample Configuration using Invoke-DSCResource

``` PowerShell
# Return the current configuration for xAzDoGitPermission
# Ensure is not required
$properties = @{
    ProjectName        = 'SampleProject'
    RepositoryName     = 'SampleGitRepository'
    isInherited        = $true
    Permissions        = @(
                                @{
                                    Identity = '[ProjectName]\GroupName'
                                    Permissions = @{
                                        Read = 'Allow'
                                        "Manage Notes" = 'Allow'
                                        "Contribute" = 'Deny'
                                    }
                                }
                        )
}

Invoke-DSCResource -Name 'xAzDoGitPermission' -Method Get -Property $properties -ModuleName 'AzureDevOpsDsc'
```

## Example 3: Sample Configuration to clear permissions for an identity within a group

``` PowerShell
# Remove all group members from the group.
$properties = @{
    ProjectName        = 'SampleProject'
    RepositoryName     = 'SampleGitRepository'
    isInherited        = $true
    Permissions        = @(
                                @{
                                    Identity = '[ProjectName]\GroupName'
                                    Permissions = @{}
                                }
                        )
}

Invoke-DSCResource -Name 'xAzDoGitPermission' -Method Set -Property $properties -ModuleName 'AzureDevOpsDsc'
```

## Example 4: Sample Configuration using xAzDoDSCDatum

``` YAML
parameters: {}

variables: {
  ProjectName: SampleProject,
  RepositoryName: SampleRepository
}

resources:

  - name: SampleGroup Permissions
    type: AzureDevOpsDsc/xAzDoGitPermission
    dependsOn: 
        - AzureDevOpsDsc/xAzDoProjectGroup/SampleGroupReadAccess
    properties:
      projectName: $ProjectName
      RepositoryName: $RepositoryName
      isInherited: false
      Permissions:
        - Identity: '[$ProjectName]\SampleGroupReadAccess'
          Permission:
            Read: "Allow"
            "Manage notes": "Allow"   
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
