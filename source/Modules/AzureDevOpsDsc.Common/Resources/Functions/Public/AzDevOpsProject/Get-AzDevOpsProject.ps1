<#
    .SYNOPSIS
        Returns an Azure DevOps 'Project' as identified by the 'ProjectId' and/or 'ProjectName' provided.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ProjectId
        The 'id' of the 'Project' being obtained/requested.

    .PARAMETER ProjectName
        The 'name' of the 'Project' being obtained/requested. Wildcards (e.g. '*') are allowed.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere'

        Returns all the 'Project' resources (assocated with the Organization/ApiUrl) from Azure DevOps.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectName '*'

        Returns all the 'Project' resources (assocated with the Organization/ApiUrl) from Azure DevOps.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectId 'YourProjectIdHere'

        Returns the 'Project' resources (assocated with the Organization/ApiUrl) from Azure DevOps related to the 'ProjectId' value provided.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectName 'YourProjectNameHere'

        Returns the 'Project' resources (assocated with the Organization/ApiUrl) from Azure DevOps related to the 'ProjectName' value provided.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectId 'YourProjectIdHere' -ProjectName 'YourProjectNameHere'

        Returns the 'Project' resources (assocated with the Organization/ApiUrl) from Azure DevOps related to the 'ProjectId' and 'ProjectName' value provided.
#>
function Get-AzDevOpsProject
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
        $SourceControlType = 'Git'

    )


    $OrganizationName = $Global:DSCAZDO_OrganizationName

    #
    # Construct a hashtable detailing the group
    $getGroupResult = @{
        #Reasons = $()
        Ensure = [Ensure]::Absent
        ProjectName = $ProjectName
        ProjectDescription = $ProjectDescription
        SourceControlType = $SourceControlType
        propertiesChanged = @()
        status = $null
    }

    #
    # Check the cache for the group
    $group = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    #
    # Test if the group is not in the cache
    if ($null -eq $group)
    {
        $getGroupResult.Status = [DSCGetSummaryState]::NotFound
        return $getGroupResult
    }

    #
    # Test if the group description has changed

    if ($group.Description -ne $ProjectDescription)
    {
        $getGroupResult.Status = [DSCGetSummaryState]::Changed
        $getGroupResult.propertiesChanged += 'description'
        return $getGroupResult
    }

    $getGroupResult.status = [DSCGetSummaryState]::Unchanged

    #
    # Return the group from the cache
    return ([PSCustomObject]$getGroupResult)

}
