<#
.SYNOPSIS
Retrieves the security descriptor for a project in Azure DevOps.

.DESCRIPTION
The Get-DevOpsSecurityDescriptor function retrieves the security descriptor for a project in Azure DevOps.
It uses the Azure DevOps REST API to perform a lookup and retrieve the descriptor.

.PARAMETER ProjectName
The name of the project.

.PARAMETER Organization
The name of the Azure DevOps organization.

.PARAMETER ApiVersion
The version of the Azure DevOps REST API to use. If not specified, the default version will be used.

.EXAMPLE
Get-DevOpsSecurityDescriptor -ProjectId "ProjectID" -Organization "MyOrganization"

This example retrieves the security descriptor for the project named "MyProject" in the Azure DevOps organization "MyOrganization".

#>
function Get-DevOpsSecurityDescriptor
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $ProjectId,
        [Parameter(Mandatory)]
        [string]
        $Organization,
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    # Get the project
    # Construct the URI with optional state filter
    $params = @{
        Uri = "https://dev.azure.com/{0}/_apis/graph/descriptors/{1}?api-version={2}" -f $Organization, $ProjectId, $ApiVersion
        Method = 'Get'
    }

    try
    {
        $response = Invoke-AzDevOpsApiRestMethod @params
        # Output the security descriptor
        return $response.value
    }
    catch
    {
        Write-Error "Failed to get Security Descriptor: $_"
    }

}
