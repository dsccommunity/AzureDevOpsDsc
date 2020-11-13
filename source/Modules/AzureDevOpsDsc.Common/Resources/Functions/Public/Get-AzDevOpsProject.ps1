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
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsProjectId -ProjectId $_ -IsValid })]
        [Alias('ResourceId','Id')]
        [System.String]
        $ProjectId,

        [Parameter()]
        [ValidateScript({ Test-AzDevOpsProjectName -ProjectName $_ -IsValid })]
        [Alias('Name')]
        [System.String]
        $ProjectName
    )

    # Prepare initial 'Get-AzDevOpsApiResource' function parameters
    $azDevOpsApiResourceParameters = @{
        ApiUri = $ApiUri
        Pat = $Pat
        ResourceName = 'Project'
    }
    If(![System.String]::IsNullOrWhiteSpace($ProjectId)){
        $azDevOpsApiResourceParameters.ResourceId = $ProjectId
    }

    # Obtain all 'Projects' (Note: This returns a limited set of properties, hence why subsequent calls are made)
    [System.Management.Automation.PSObject[]]$apiListResources = Get-AzDevOpsApiResource @azDevOpsApiResourceParameters
    [System.Management.Automation.PSObject[]]$projects = @()

    # Filter projects by 'ProjectId'
    If(![System.String]::IsNullOrWhiteSpace($ProjectId)){
        $apiListResources = $apiListResources |
            Where-Object id -eq $ProjectId
    }

    # Filter projects by 'ProjectName' (using 'ilike')
    If(![System.String]::IsNullOrWhiteSpace($ProjectName)){
        $apiListResources = $apiListResources |
            Where-Object name -ilike $ProjectName
    }

    # For each project (if any), call 'Get-AzDevOpsApiResource' again to obtain all 'Project' properties
    if ($apiListResources.Count -gt 0)
    {
        $apiListResources | ForEach-Object {
            $azDevOpsApiResourceParameters.ResourceId = $_.id
            $projects += $(Get-AzDevOpsApiResource @azDevOpsApiResourceParameters)
        }
    }

    return [System.Management.Automation.PSObject[]]$projects
}
