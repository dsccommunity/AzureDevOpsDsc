function AzDoAPI_8_ProjectProcessTemplates
{
    [CmdletBinding()]
    param(
        [string]$OrganizationName
    )

    # Use a verbose statement to indicate the start of the function.
    Write-Verbose "[AzDoAPI_8_ProjectProcessTemplates] Starting 'AzDoAPI_8_ProjectProcessTemplates' function."

    if (-not $OrganizationName)
    {
        Write-Verbose "[AzDoAPI_8_ProjectProcessTemplates] No organization name provided as parameter; using global variable."
        $OrganizationName = $Global:DSCAZDO_OrganizationName
    }

    # Construct the parameters for the API request
    $params = @{
        Organization = $OrganizationName
    }

    try
    {
        Write-Verbose "[AzDoAPI_8_ProjectProcessTemplates] Calling 'List-DevOpsProcess' with parameters: $($params | Out-String)"
        # Perform an Azure DevOps API request to get the groups

        $processes = List-DevOpsProcess @params

        # Iterate through each of the responses and add them to the cache
        foreach ($process in $processes)
        {
            Write-Verbose "[AzDoAPI_8_ProjectProcessTemplates] Adding process '$($process.name)' to cache."
            # Add the group to the cache
            Add-CacheItem -Key $process.name -Value $process -Type 'LiveProcesses'
        }

        # Export the cache to a file
        Export-CacheObject -CacheType 'LiveProcesses' -Content $AzDoLiveProcesses

        Write-Verbose "[AzDoAPI_8_ProjectProcessTemplates] Completed adding processes to cache."

    }
    catch
    {
        Write-Error "[AzDoAPI_8_ProjectProcessTemplates] An error occurred: $_"
    }

    Write-Verbose "[AzDoAPI_8_ProjectProcessTemplates] Function completed."

}
