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
        The 'id' of the 'Project' being obtained/requested. Wildcards (e.g. '*') are allowed.

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
    [OutputType([System.Object[]])]
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


    $azDevOpsApiResourceParameters = @{
        ApiUri = $ApiUri;
        Pat = $Pat;
        ResourceName = 'Project'}


    If(![string]::IsNullOrWhiteSpace($ProjectId)){
        $azDevOpsApiResourceParameters.ResourceId = $ProjectId
    }


    [object[]]$apiListResources = Get-AzDevOpsApiResource @azDevOpsApiResourceParameters


    If(![string]::IsNullOrWhiteSpace($ProjectId)){
        $apiListResources = $apiListResources |
            Where-Object id -ilike $ProjectId
    }


    If(![string]::IsNullOrWhiteSpace($ProjectName)){
        $apiListResources = $apiListResources |
            Where-Object name -ilike $ProjectName
    }

    [object[]]$projects = @()

    if ($apiListResources.Count -gt 0)
    {
        $apiListResources |
            ForEach-Object {

                $azDevOpsProjectParameters = @{
                    ApiUri = $ApiUri;
                    Pat = $Pat;
                    ResourceName = 'Project'
                    ResourceId = $_.id}
                $projects += $(Get-AzDevOpsApiResource @azDevOpsProjectParameters)
            }
    }
    return [object[]]$projects
}
