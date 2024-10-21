<#
.SYNOPSIS
Retrieves the status of a specified project service in Azure DevOps.

.DESCRIPTION
The Get-ProjectServiceStatus function retrieves the status of a specified service within a project in Azure DevOps.
It constructs the appropriate URI and makes a REST API call to fetch the service status. If the service status is
'undefined', it is treated as 'enabled'.

.PARAMETER Organization
The name of the Azure DevOps organization.

.PARAMETER ProjectId
The ID of the project in Azure DevOps.

.PARAMETER ServiceName
The name of the service whose status is to be retrieved.

.PARAMETER ApiVersion
The API version to use for the request. If not specified, the default API version is used.

.OUTPUTS
System.Object
Returns the state of the specified service.

.EXAMPLE
PS> Get-ProjectServiceStatus -Organization "MyOrg" -ProjectId "12345" -ServiceName "MyService"
This command retrieves the status of the service "MyService" in the project with ID "12345" within the organization "MyOrg".

.NOTES
If the service status is 'undefined', it is treated as 'enabled'.
#>
function Get-ProjectServiceStatus
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$ServiceName,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    # Get the project
    # Construct the URI with optional state filter
    $params = @{
        Uri = 'https://dev.azure.com/{0}/_apis/FeatureManagement/FeatureStates/host/project/{1}/{2}?api-version={3}' -f $Organization, $ProjectId, $ServiceName, $ApiVersion
        Method = 'Get'
    }

    try
    {
        $response = Invoke-AzDevOpsApiRestMethod @params
        # If the service is 'undefined' then treat it as 'enabled'
        if ($response.state -eq 'undefined')
        {
            $response.state = 'enabled'
        }

        # Output the state of the service
        return $response
    }
    catch
    {
        Write-Error "Failed to get Security Descriptor: $_"
    }

}
