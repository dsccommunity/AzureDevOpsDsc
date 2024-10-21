<#
.SYNOPSIS
Creates a new Azure DevOps Git repository within a specified project.

.DESCRIPTION
The New-AzDoGitRepository function creates a new Git repository in an Azure DevOps project.
It uses the provided project name and repository name to create the repository.
Optionally, a source repository can be specified to initialize the new repository.

.PARAMETER ProjectName
The name of the Azure DevOps project where the new repository will be created.

.PARAMETER RepositoryName
The name of the new Git repository to be created.

.PARAMETER SourceRepository
(Optional) The name of the source repository to initialize the new repository.

.PARAMETER LookupResult
(Optional) A hashtable to store lookup results.

.PARAMETER Ensure
(Optional) Specifies whether to ensure the repository exists or does not exist.

.PARAMETER Force
(Optional) Forces the creation of the repository even if it already exists.

.EXAMPLE
PS> New-AzDoGitRepository -ProjectName "MyProject" -RepositoryName "MyRepo"

Creates a new Git repository named "MyRepo" in the "MyProject" Azure DevOps project.

.EXAMPLE
PS> New-AzDoGitRepository -ProjectName "MyProject" -RepositoryName "MyRepo" -SourceRepository "TemplateRepo"

Creates a new Git repository named "MyRepo" in the "MyProject" Azure DevOps project, initialized with the contents of "TemplateRepo".

.NOTES
This function requires the Azure DevOps organization name to be set in the global variable $Global:DSCAZDO_OrganizationName.
#>

Function New-AzDoGitRepository
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$ProjectName,

        [Parameter(Mandatory = $true)]
        [Alias('Repository')]
        [System.String]$RepositoryName,

        [Parameter()]
        [Alias('Source')]
        [System.String]$SourceRepository,

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Write-Verbose "[New-AzDoGitRepository] Creating new repository '$($RepositoryName)' in project '$($ProjectName)'"

    # Define parameters for creating a new DevOps group
    $params = @{
        ApiUri = 'https://dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
        Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'
        RepositoryName = $RepositoryName
        SourceRepository = $SourceRepository
    }

    if ($null -eq $params.Project)
    {
        Write-Error "[New-AzDoGitRepository] Project '$($ProjectName)' does not exist in the LiveProjects cache. Skipping change."
        return
    }


    # Create a new repository
    $value = New-GitRepository @params

    # Add the repository to the LiveRepositories cache and write to verbose log
    Add-CacheItem -Key "$ProjectName\$RepositoryName" -Value $value -Type 'LiveRepositories'
    Export-CacheObject -CacheType 'LiveRepositories' -Content $AzDoLiveRepositories
    Refresh-CacheObject -CacheType 'LiveRepositories'
    Write-Verbose "[New-AzDoGitRepository] Added new group to LiveGroups cache with key: '$($value.Name)'"

}
