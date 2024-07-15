

Function Set-xAzDoGitPermission
{
    param(
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [string]$SecurityNamespaceID,

        [Parameter(Mandatory)]
        [Object]$SerializedACLs,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    Write-Verbose "[Set-xAzDoGitPermission] Started."

    # Define a hashtable to store parameters for the Invoke-AzDevOpsApiRestMethod function.

    $params = @{
        # Construct the Uri using string formatting with the -f operator.
        # It includes the API endpoint, group identity, member identity, and the API version.
        Uri = "https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?api-version={2}" -f   $OrganizationName,
                                                                                            $SecurityNamespaceID,
                                                                                            $ApiVersion
        # Set the method to PUT.
        Method = 'POST'
        # Set the body of the request to the serialized ACLs.
        Body = $SerializedACLs | ConvertTo-Json -Depth 4
    }

    try {
        # Call the Invoke-AzDevOpsApiRestMethod function with the parameters defined above.
        # The "@" symbol is used to pass the hashtable as splatting parameters.
        Write-Verbose "[Set-xAzDoGitPermission] Attempting to invoke REST method to set ACLs."
        $null = Invoke-AzDevOpsApiRestMethod @params

    } catch {
        # If an exception occurs, write an error message to the console with details about the issue.
        Write-Error "[Set-xAzDoGitPermission] Failed to set ACLs: $($_.Exception.Message)"
    }

}
