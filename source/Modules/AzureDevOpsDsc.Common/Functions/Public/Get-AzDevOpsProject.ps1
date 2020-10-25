<#
    .SYNOPSIS
        Returns an Azure DevOps 'Project' as identified by the 'ProjectId' and/or 'ProjectName' provided.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/Projects
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent Projects being performed.

    .PARAMETER ProjectId
        The 'id' of the 'Project' being obtained/requested. Wildcards (e.g. '*') are allowed.

    .PARAMETER ProjectName
        The 'name' of the 'Project' being obtained/requested. Wildcards (e.g. '*') are allowed.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere'

        Returns all the 'Project' objects (assocated with the Organization/ApiUrl) from Azure DevOps.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectName '*'

        Returns all the 'Project' objects (assocated with the Organization/ApiUrl) from Azure DevOps.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectId 'YourProjectIdHere'

        Returns the 'Project' objects (assocated with the Organization/ApiUrl) from Azure DevOps related to the 'ProjectId' value provided.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectName 'YourProjectNameHere'

        Returns the 'Project' objects (assocated with the Organization/ApiUrl) from Azure DevOps related to the 'ProjectName' value provided.

    .EXAMPLE
        Get-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectId 'YourProjectIdHere' -ProjectName 'YourProjectNameHere'

        Returns the 'Project' objects (assocated with the Organization/ApiUrl) from Azure DevOps related to the 'ProjectId' and 'ProjectName' value provided.
#>
function Get-AzDevOpsProject
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter(Mandatory = $true)]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory = $true)]
        [Alias('Id')]
        [System.String]
        $ProjectId = '*',

        [Parameter()]
        [Alias('Name')]
        [System.String]
        $ProjectName = '*'
    )

    [object[]]$apiObjects = Get-AzDevOpsApiObject -ApiUri $ApiUri -Pat $Pat `
                                                  -ObjectName 'Project' `
                                                  -ObjectId $ProjectId

    return $apiObjects |
        Where-Object name -ilike $ProjectName |
        Where-Object id -ilike $ProjectId
  }
