function AzDoAPI_6_ServicePrinciple
{
    [CmdletBinding()]
    param(
        [string]$OrganizationName
    )

    # Use a verbose statement to indicate the start of the function.
    Write-Verbose "Starting [AzDoAPI_6_ServicePrinciple] function."

    if (-not $OrganizationName)
    {
        Write-Verbose "No organization name provided as parameter; using global variable."
        $OrganizationName = $Global:DSCAZDO_OrganizationName
    }

    $params = @{
        Organization = $OrganizationName
    }

    try
    {
        Write-Verbose "[AzDoAPI_6_ServicePrinciple] with parameters: $($params | Out-String)"
        # Perform an Azure DevOps API request to get the groups

        $serviceprincipals = List-DevOpsServicePrinciples @params

        Write-Verbose "[AzDoAPI_6_ServicePrinciple] returned a total of $($serviceprincipals.Count) serviceprincipals."

        # Iterate through each of the responses and add them to the cache
        foreach ($serviceprincipal in $serviceprincipals)
        {
            Write-Verbose "[AzDoAPI_6_ServicePrinciple] Adding serviceprincipal '$($serviceprincipal.displayName)' to cache."
            # Add the group to the cache
            Add-CacheItem -Key $serviceprincipal.DisplayName -Value $serviceprincipal -Type 'LiveServicePrinciples'
        }

        # Export the cache to a file
        Export-CacheObject -CacheType 'LiveServicePrinciples' -Content $AzDoLiveServicePrinciples

        Write-Verbose "[AzDoAPI_6_ServicePrinciple]  Completed adding serviceprincipals to cache."

    }
    catch
    {
        Write-Error "An error occurred: $_"
    }


}
