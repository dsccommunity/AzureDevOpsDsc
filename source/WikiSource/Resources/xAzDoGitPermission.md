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

## Permissions Syntax:

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

> Either 'Name' or 'Display Name' can be used

| Name      | Display Name      | Values | Note |
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

# Additional Information

# Example
