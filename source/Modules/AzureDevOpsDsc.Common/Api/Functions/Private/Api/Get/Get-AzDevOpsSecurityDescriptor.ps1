<#
.SYNOPSIS
Retrieves the security descriptor for a project in Azure DevOps.

.DESCRIPTION
The Get-AzDevOpsSecurityDescriptor function retrieves the security descriptor for a project in Azure DevOps.
It uses the Azure DevOps REST API to perform a lookup and retrieve the descriptor.

.PARAMETER ProjectName
The name of the project.

.PARAMETER Organization
The name of the Azure DevOps organization.

.PARAMETER ApiVersion
The version of the Azure DevOps REST API to use. If not specified, the default version will be used.

.EXAMPLE
Get-AzDevOpsSecurityDescriptor -ProjectName "MyProject" -Organization "MyOrganization"

This example retrieves the security descriptor for the project named "MyProject" in the Azure DevOps organization "MyOrganization".

#>
function Get-AzDevOpsSecurityDescriptor {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]
        $ProjectName,
        [Parameter(Mandatory)]
        [string]
        $Organization,
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    #
    # Extract the Project Name from the LiveCache
    $project = Get-CacheItem -Key $ProjectName -Type 'ProjectLive'

    # If the project does not exist in the cache, throw an error.
    if (-not $project) {
        throw "Project with name '$ProjectName' does not exist in the cache."
    }

    # Perform a Lookup to get the descriptor using the project id.

    # Construct the URI with optional state filter
    $params = @{
        Uri = "https://dev.azure.com/$Organization/_apis/graph/descriptors/{0}?api-version={1}" -f $project.id, $ApiVersion
        Method = 'Get'
    }

    try {

        $response = Invoke-AzDevOpsApiRestMethod @params
        # Output the security descriptor
        return $response.value

    } catch {
        Write-Error "Failed to get Security Descriptor: $_"
    }

}
