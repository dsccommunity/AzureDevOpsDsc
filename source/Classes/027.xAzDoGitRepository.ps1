<#
.SYNOPSIS
    This class represents an Azure DevOps Git repository.

.DESCRIPTION
    The xAzDoGitRepository class is a DSC resource that allows you to manage Azure DevOps Git repositories.
    It inherits from the AzDevOpsDscResourceBase class.

.NOTES
    Author: Your Name
    Date:   Current Date

.LINK
    GitHub Repository: <link to the GitHub repository>

.PARAMETER ProjectName
    The name of the Azure DevOps project where the Git repository is located.

.PARAMETER GitRepositoryName
    The name of the Git repository.

.PARAMETER SourceRepository
    The source repository URL.

.EXAMPLE
    This example shows how to use the xAzDoGitRepository resource to ensure that a Git repository exists in an Azure DevOps project.

    Configuration Example {
        Import-DscResource -ModuleName xAzDoGitRepository

        xAzDoGitRepository MyGitRepository {
            ProjectName = 'MyProject'
            GitRepositoryName = 'MyRepository'
            SourceRepository = 'https://github.com/MyUser/MyRepository.git'
            Ensure = 'Present'
        }
    }

.INPUTS
    None

.OUTPUTS
    None
#>

[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class xAzDoGitRepository : AzDevOpsDscResourceBase
{
    [DscProperty(Mandatory)]
    [Alias('Name')]
    [System.String]$ProjectName

    [DscProperty(Key, Mandatory)]
    [Alias('Repository')]
    [System.String]$RepositoryName

    [DscProperty()]
    [Alias('Source')]
    [System.String]$SourceRepository

    xAzDoGitRepository()
    {
        $this.Construct()
    }

    [xAzDoGitRepository] Get()
    {
        return [xAzDoGitRepository]$($this.GetDscCurrentStateProperties())
    }

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @()
    }

    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Ensure = [Ensure]::Absent
        }

        # If the resource object is null, return the properties
        if ($null -eq $CurrentResourceObject) { return $properties }

        $properties.ProjectName         = $CurrentResourceObject.Name
        $properties.GitRepositoryName   = $CurrentResourceObject.Repository
        $properties.SourceRepository    = $CurrentResourceObject.Source
        $properties.Ensure              = $CurrentResourceObject.Ensure
        $properties.LookupResult        = $CurrentResourceObject.LookupResult

        Write-Verbose "[xAzDoProjectGroup] Current state properties: $($properties | Out-String)"

        return $properties
    }

}
