function Remove-AzDevOpsProject
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter()]
        [ValidateScript({ Test-AzDevOpsProjectName -ProjectName $_ -IsValid -AllowWildcard })]
        [Alias('Name')]
        [System.String]
        $ProjectName,

        [Parameter()]
        [Alias('Description')]
        [System.String]
        $ProjectDescription,

        [Parameter()]
        [ValidateSet('Git','Tfvc')]
        [System.String]
        $SourceControlType = 'Git',

        [Parameter()]
        [ValidateSet('Agile', 'Scrum', 'CMMI', 'Basic')]
        [System.String]$ProcessTemplate = 'Agile',

        [Parameter()]
        [ValidateSet('Public', 'Private')]
        [System.String]$Visibility = 'Private'

    )

    # Set the organization name
    $OrganizationName = $Global:DSCAZDO_OrganizationName

    #
    # Perform a lookup to see if the group exists in Azure DevOps
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    # Remove the project
    Remove-DevOpsProject -Organization $OrganizationName -ProjectId $project.id

    # Remove the project from the cache and export the cache
    Remove-CacheItem -Key $ProjectName -Type 'LiveProjects'
    Export-CacheObject -CacheType 'LiveProjects' -Content $AzDoLiveProjects

}
