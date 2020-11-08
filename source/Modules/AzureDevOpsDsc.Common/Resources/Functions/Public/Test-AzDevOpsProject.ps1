<#
    .SYNOPSIS
        Tests the presence of an Azure DevOps API project.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/projects
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ProjectId
        The 'id' of the Azure DevOps API project.

    .PARAMETER ProjectName
        The 'name' of the Azure DevOps API project.

    .EXAMPLE
        Test-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectId 'YourProjectId'

        Tests that the Azure DevOps 'Project' (identified by the 'ProjectId') exists.

    .EXAMPLE
        Test-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' -ProjectId 'YourProjectName'

        Tests that the Azure DevOps 'Project' (identified by the 'ProjectName') exists.

    .EXAMPLE
        Test-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' `
                             -ProjectId 'YourProjectId' -ProjectId 'YourProjectName'

        Tests that the Azure DevOps 'Project' (identified by the 'ProjectId' and 'ProjectName') exists.
#>
function Test-AzDevOpsProject
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
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

        [Parameter(Mandatory = $true, ParameterSetName='ProjectId')]
        [Parameter(Mandatory = $true, ParameterSetName='ProjectIdAndProjectName')]
        [ValidateScript({ Test-AzDevOpsProjectId -ProjectId $_ -IsValid })]
        [Alias('ResourceId','Id')]
        [System.String]
        $ProjectId,

        [Parameter(Mandatory = $true, ParameterSetName='ProjectName')]
        [Parameter(Mandatory = $true, ParameterSetName='ProjectIdAndProjectName')]
        [ValidateScript({ Test-AzDevOpsProjectName -ProjectName $_ -IsValid })]
        [Alias('Name')]
        [System.String]
        $ProjectName
    )

    $azDevOpsProjectParameters = @{
        ApiUri = $ApiUri;
        Pat = $Pat
    }

    If(![string]::IsNullOrWhiteSpace($ProjectId)){
        $azDevOpsProjectParameters.ProjectId = $ProjectId
    }

    If(![string]::IsNullOrWhiteSpace($ProjectName)){
        $azDevOpsProjectParameters.ProjectName = $ProjectName
    }

    [object[]]$project = Get-AzDevOpsProject @azDevOpsProjectParameters


    return $($null -ne $project.id)
}
