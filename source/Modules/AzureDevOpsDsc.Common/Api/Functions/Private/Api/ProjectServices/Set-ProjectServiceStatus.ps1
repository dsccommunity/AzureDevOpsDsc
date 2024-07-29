function Set-ProjectServiceStatus
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$ServiceName
    )

    # Get the project
    # Construct the URI with optional state filter
    $params = @{
        Uri = 'https://dev.azure.com/{0}/_apis/FeatureManagement/FeatureStates/host/project/{1}/{2}' -f $Organization, $ProjectId, $ServiceName
        Method = 'PATCH'
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
