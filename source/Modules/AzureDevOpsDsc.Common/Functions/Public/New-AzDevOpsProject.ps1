<#
    .SYNOPSIS
        Creates a new Azure DevOps 'Project' with the specified properties set by the parameters.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ProjectId
        The 'id' of the 'Project' being created.

    .PARAMETER ProjectName
        The 'name' of the 'Project' being created.

    .PARAMETER ProjectDescription
        The 'description' of the 'Project' being created.

    .PARAMETER SourceControlType
        The 'sourceControlType' of the 'Project' being created.

        Options are 'Tfvc' or 'Git'. Defaults to 'Git' if no value provided.

    .PARAMETER Force
        When this switch is used, any confirmation will be overidden/ignored.

    .EXAMPLE
        New-AzDevOpsProject -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' `
                            -ProjectId 'YourProjectIdHere' -ProjectName 'YourProjectNameHere' `
                            -ProjectName 'YourProjectDescriptionHere' -SourceControlType 'Git'

        Creates a 'Project' (assocated with the Organization/ApiUrl) in Azure DevOps using project-related, parameter values provided.
#>
function New-AzDevOpsProject
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Object])]
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
        $ProjectId,

        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]
        $ProjectName,

        [Parameter(Mandatory = $true)]
        [Alias('Description')]
        [System.String]
        $ProjectDescription,

        [Parameter()]
        [ValidateSet('Git','Tfvc')]
        [System.String]
        $SourceControlType = 'Git',

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    [string]$objectJson = '
    {
      "id": "' + $ProjectId + '",
      "name": "' + $ProjectName + '",
      "description": "' + $ProjectDescription + '",
      "capabilities": {
        "versioncontrol": {
          "sourceControlType": "' + $SourceControlType + '"
        },
        "processTemplate": {
          "templateTypeId": "6b724908-ef14-45cf-84f8-768b5384da45"
        }
      }
    }
'

    [System.Object]$object = $null

    if ($Force -or $PSCmdlet.ShouldProcess($ApiUri, $objectName))
    {
        [System.Object]$object = New-AzDevOpsApiObject -$ApiUri $ApiUri -Pat $Pat `
                                                       -ObjectName 'Project' `
                                                       -Object $($objectJson | ConvertFrom-Json) `
                                                       -Force:$Force
    }

    return $object
}
