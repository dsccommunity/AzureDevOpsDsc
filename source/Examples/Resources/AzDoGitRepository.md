# DSC AzDoGitRepository Resource

## Syntax

```PowerShell
AzDoGitRepository [string] #ResourceName
{
    ProjectName = [String]$ProjectName
    RepositoryName = [String]$RepositoryName
    [ SourceRepository = [String]$SourceRepository ]
    [ Ensure = [String] {'Present', 'Absent'}]
}
```

## Permissions Syntax

This resource does not directly manage permissions. It focuses on managing Git repositories within an Azure DevOps project.

## Permission Usage

Not applicable for this resource.

## Permission List

Not applicable for this resource.

## Common Properties

- __Ensure__: Specifies whether the repository should exist. Defaults to 'Absent'.
- __ProjectName__: The name of the Azure DevOps project.
- __RepositoryName__: The name of the Git repository within the project.
- __SourceRepository__: (Optional) The source repository from which to create the new repository.

## Additional Information

This resource allows you to manage Git repositories in Azure DevOps projects using Desired State Configuration (DSC). It includes properties for specifying the project name, repository name, and optionally a source repository.

## Examples

### Example 1: Create a Git Repository

```PowerShell
Configuration Sample_AzDoGitRepository
{
    Import-DscResource -ModuleName AzDevOpsDsc

    Node localhost
    {
        AzDoGitRepository MyRepository
        {
            ProjectName      = 'MySampleProject'
            RepositoryName   = 'MySampleRepository'
            SourceRepository = 'TemplateRepository'
            Ensure           = 'Present'
        }
    }
}

Sample_AzDoGitRepository -OutputPath 'C:\DSC\'
Start-DscConfiguration -Path 'C:\DSC\' -Wait -Verbose -Force
```

### Example 2: Remove a Git Repository

```PowerShell
Configuration Remove_AzDoGitRepository
{
    Import-DscResource -ModuleName AzDevOpsDsc

    Node localhost
    {
        AzDoGitRepository MyRepository
        {
            ProjectName    = 'MySampleProject'
            RepositoryName = 'MySampleRepository'
            Ensure         = 'Absent'
        }
    }
}

Remove_AzDoGitRepository -OutputPath 'C:\DSC\'
Start-DscConfiguration -Path 'C:\DSC\' -Wait -Verbose -Force
```
