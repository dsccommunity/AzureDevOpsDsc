function Remove-xAzDoProject
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateScript({ Test-AzDevOpsProjectName -ProjectName $_ -IsValid -AllowWildcard })]
        [Alias('Name')]
        [System.String] $ProjectName,

        [Parameter()]
        [Alias('Description')]
        [System.String] $ProjectDescription,

        [Parameter()]
        [ValidateSet('Git', 'Tfvc')]
        [System.String] $SourceControlType = 'Git',

        [Parameter()]
        [ValidateSet('Agile', 'Scrum', 'CMMI', 'Basic')]
        [System.String] $ProcessTemplate = 'Agile',

        [Parameter()]
        [ValidateSet('Public', 'Private')]
        [System.String] $Visibility = 'Private',

        [Parameter()]
        [HashTable] $LookupResult,

        [Parameter()]
        [Ensure] $Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Force
    )

    # Set the organization name
    $OrganizationName = $Global:DSCAZDO_OrganizationName
    Write-Verbose "[Remove-xAzDoProject] Using organization name: $OrganizationName"

    # Perform a lookup to see if the group exists in Azure DevOps
    Write-Verbose "[Remove-xAzDoProject] Looking up project: $ProjectName"
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    if ($null -eq $project)
    {
        Write-Verbose "[Remove-xAzDoProject] Project $ProjectName not found in cache."
        return
    }

    Write-Verbose "[Remove-xAzDoProject] Found project $ProjectName with ID: $($project.id)"

    # Remove the project
    Write-Verbose "[Remove-xAzDoProject] Removing project $ProjectName from Azure DevOps"
    Remove-DevOpsProject -Organization $OrganizationName -ProjectId $project.id

    # Remove the project from the cache and export the cache
    Write-Verbose "[Remove-xAzDoProject] Removing project $ProjectName from local cache"
    Remove-CacheItem -Key $ProjectName -Type 'LiveProjects'

    Write-Verbose "[Remove-xAzDoProject] Exporting updated cache object for LiveProjects"
    Export-CacheObject -CacheType 'LiveProjects' -Content $AzDoLiveProjects
}
