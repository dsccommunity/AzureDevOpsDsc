<#
.SYNOPSIS
Removes a group from Azure DevOps.

.DESCRIPTION
The Remove-AzDevOpsGroup function is used to remove a group from Azure DevOps using the Azure DevOps REST API.

.PARAMETER ApiUri
The mandatory parameter for the API URI.

.PARAMETER ApiVersion
The optional parameter for the API version with a default value obtained from the Get-AzDevOpsApiVersion function.

.PARAMETER GroupDescriptor
The optional parameter for the project scope descriptor.

.OUTPUTS
System.Management.Automation.PSObject

.EXAMPLE
Remove-AzDevOpsGroup -ApiUri "https://dev.azure.com/myorganization" -GroupDescriptor "MyGroup"

This example removes the group with the specified group descriptor from Azure DevOps.

#>

Function Remove-AzDevOpsGroup {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $ApiUri,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default),

        [Parameter()]
        [String]
        $GroupDescriptor
    )

    $params = @{
        Uri = "{0}/_apis/graph/groups/{1}?api-version={2}" -f $ApiUri, $GroupDescriptor, $ApiVersion
        Method = 'Delete'
        ContentType = 'application/json'
    }

    try {
        return (Invoke-AzDevOpsApiRestMethod @params)
    }
    catch {
        Write-Error "Failed to remove group: $_"
    }
}
