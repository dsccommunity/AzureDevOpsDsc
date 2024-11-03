# AzDoGroupPermission Resource Documentation (Currently Disabled)

## Overview

The `AzDoGroupPermission` resource is part of the Azure DevOps Desired State Configuration (DSC) module. It allows you to manage group permissions within an Azure DevOps project repository. This resource provides properties for specifying the group name, permission inheritance, and a list of permissions to be set.

## Syntax

```PowerShell
AzDoGroupPermission [string] #ResourceName
{
    GroupName = [String]$GroupName
    [ isInherited = [Boolean]$isInherited ]
    [ Permissions = [HashTable[]]$Permissions ]
}
```

### Properties

- **GroupName**: The name of the Azure DevOps group. This property is mandatory.
- **isInherited**: Specifies whether the permissions should be inherited. Defaults to `$true`.
- **Permissions**: A HashTable array that specifies the permissions to be set for the group. Refer to the 'Permissions Syntax' section below.

## Permissions Syntax

```PowerShell
AzDoGroupPermission/Permissions
{
    Identity = [String]$Identity
    #   SYNTAX:     '[ProjectName | OrganizationName]\ServicePrincipalName, UserPrincipalName, UserDisplayName, GroupDisplayName'
    #   ALTERNATIVE SYNTAX: 'this' Referring to the group.
    #   EXAMPLE:    '[TestProject]\UserName@email.com'
    #   EXAMPLE:    '[SampleOrganizationName]\Project Collection Administrators'
    Permission = [Hashtable[]]$Permissions
}
```

### Permission Usage

```PowerShell
AzDoGroupPermission/Permissions/Permission
{
    PermissionName|PermissionDisplayName = [String]$Name { 'Allow, Deny' }
}
```

### Permission List

Either 'Name' or 'DisplayName' can be used:

| Name                    | DisplayName                                          | Values          | Note             |
|-------------------------|------------------------------------------------------|-----------------|------------------|
| Read              | View identity information                                           | [ allow, deny ] | |
| Write             | Edit identity information                                                 | [ allow, deny ] |                  |
| Delete       | Delete identity information                                           | [ allow, deny ] |                  |
| ManageMembership               |  Manage group membership | [ allow, deny ] |                  |
| CreateScope            | Create identity scopes                                       | [ allow, deny ] |                  |
| RestoreScope               | Restore identity scopes                                           | [ allow, deny ] |                  |

## Examples

### Example 1: Set Group Permissions

```PowerShell
Configuration ExampleConfig {
    Import-DscResource -ModuleName 'AzDevOpsDsc'

    Node localhost {
        AzDoGroupPermission GroupPermission {
            GroupName        = 'SampleGroup'
            isInherited      = $true
            Permissions      = @(
                @{
                    Identity = '[SampleProject]\SampleGroup'
                    Permissions = @{
                        "Read"      = 'Allow'
                        "Write"     = 'Allow'
                        "Delete"    = 'Deny'
                    }
                }
            )
        }
    }
}

ExampleConfig
Start-DscConfiguration -Path ./ExampleConfig -Wait -Verbose
```

### Example 2: Clear Group Permissions

```PowerShell
# Remove all permissions from the group.
$properties = @{
    GroupName        = 'SampleGroup'
    isInherited      = $true
    Permissions      = @(
                            @{
                                Identity = '[SampleProject]\SampleGroup'
                                Permissions = @{}
                            }
                      )
}

Invoke-DSCResource -Name 'AzDoGroupPermission' -Method Set -Property $properties -ModuleName 'AzureDevOpsDsc'
```

## Methods

### Get Method

Retrieves the current state properties of the `AzDoGroupPermission` resource.

```PowerShell
[AzDoGroupPermission] Get()
{
    return [AzDoGroupPermission]$($this.GetDscCurrentStateProperties())
}
```

### GetDscCurrentStateProperties Method

Returns the current state properties of the resource object.

```PowerShell
hidden [Hashtable] GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
{
    $properties = @{
        Ensure = [Ensure]::Absent
    }

    if ($null -eq $CurrentResourceObject)
    {
        return $properties
    }

    $properties.GroupName   = $CurrentResourceObject.GroupName
    $properties.isInherited = $CurrentResourceObject.isInherited
    $properties.Permissions = $CurrentResourceObject.Permissions

    Write-Verbose "[AzDoGroupPermission] Current state properties: $($properties | Out-String)"

    return $properties
}
```

This class inherits from the `AzDevOpsDscResourceBase` class, which provides the base functionality for DSC resources in the Azure DevOps DSC module.
