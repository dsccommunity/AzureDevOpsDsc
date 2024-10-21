<#
.SYNOPSIS
Removes an Azure DevOps project.

.DESCRIPTION
The Remove-AzDoProject function removes a specified project from Azure DevOps. It performs a lookup to check if the project exists in the cache, removes it from Azure DevOps, and updates the local cache accordingly.

.PARAMETER ProjectName
Specifies the name of the Azure DevOps project to be removed. This parameter is validated using the Test-AzDevOpsProjectName function.

.PARAMETER ProjectDescription
Specifies the description of the Azure DevOps project.

.PARAMETER SourceControlType
Specifies the type of source control for the project. Valid values are 'Git' and 'Tfvc'. The default value is 'Git'.

.PARAMETER ProcessTemplate
Specifies the process template for the project. Valid values are 'Agile', 'Scrum', 'CMMI', and 'Basic'. The default value is 'Agile'.

.PARAMETER Visibility
Specifies the visibility of the project. Valid values are 'Public' and 'Private'. The default value is 'Private'.

.PARAMETER LookupResult
Specifies a hashtable to store the lookup result.

.PARAMETER Ensure
Specifies the desired state of the project.

.PARAMETER Force
Forces the removal of the project without prompting for confirmation.

.EXAMPLE
Remove-AzDoProject -ProjectName "MyProject" -Force

This command removes the Azure DevOps project named "MyProject" without prompting for confirmation.

.NOTES
The function uses global variable $Global:DSCAZDO_OrganizationName to get the organization name.
#>
function Remove-AzDoProject
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
    Write-Verbose "[Remove-AzDoProject] Using organization name: $OrganizationName"

    # Perform a lookup to see if the group exists in Azure DevOps
    Write-Verbose "[Remove-AzDoProject] Looking up project: $ProjectName"
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    if ($null -eq $project)
    {
        Write-Verbose "[Remove-AzDoProject] Project $ProjectName not found in cache."
        return
    }

    Write-Verbose "[Remove-AzDoProject] Found project $ProjectName with ID: $($project.id)"

    # Remove the project
    Write-Verbose "[Remove-AzDoProject] Removing project $ProjectName from Azure DevOps"
    Remove-DevOpsProject -Organization $OrganizationName -ProjectId $project.id

    # Remove the project from the cache and export the cache
    Write-Verbose "[Remove-AzDoProject] Removing project $ProjectName from local cache"
    Remove-CacheItem -Key $ProjectName -Type 'LiveProjects'

    Write-Verbose "[Remove-AzDoProject] Exporting updated cache object for LiveProjects"
    Export-CacheObject -CacheType 'LiveProjects' -Content $AzDoLiveProjects
}
