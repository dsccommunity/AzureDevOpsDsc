<#
.SYNOPSIS
Sets the status of a specified project service in Azure DevOps.

.DESCRIPTION
The Set-ProjectServiceStatus function updates the status of a specified service within a given project in an Azure DevOps organization. It constructs the appropriate URI and sends a PATCH request with the provided body content.

.PARAMETER Organization
The name of the Azure DevOps organization.

.PARAMETER ProjectId
The ID of the project within the Azure DevOps organization.

.PARAMETER ServiceName
The name of the service whose status is to be set.

.PARAMETER Body
The body content to be sent in the PATCH request. This should be an object that will be converted to JSON.

.PARAMETER ApiVersion
The API version to use for the request. If not specified, the default API version is retrieved using Get-AzDevOpsApiVersion.

.EXAMPLE
Set-ProjectServiceStatus -Organization "myOrg" -ProjectId "12345" -ServiceName "myService" -Body $bodyContent

.NOTES
This function requires the Azure DevOps REST API and the Invoke-AzDevOpsApiRestMethod cmdlet to be available.
#>
function Set-ProjectServiceStatus
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$ServiceName,

        [Parameter(Mandatory = $true)]
        [Object]$Body,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    # Get the project
    # Construct the URI with optional state filter
    $params = @{
        Uri = 'https://dev.azure.com/{0}/_apis/FeatureManagement/FeatureStates/host/project/{1}/{2}?api-version={3}' -f $Organization, $ProjectId, $ServiceName, $ApiVersion
        Method = 'PATCH'
        Body = $Body | ConvertTo-Json
    }

    try
    {
        $response = Invoke-AzDevOpsApiRestMethod @params
        # Output the state of the service
        return $response.state
    }
    catch
    {
        Write-Error "Failed to set Security Descriptor: $_"
    }

}
