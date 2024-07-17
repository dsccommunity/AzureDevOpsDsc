Function Remove-xAzDoPermission
{
    param(
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [string]$SecurityNamespaceID,

        [Parameter(Mandatory)]
        [string]$TokenName,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    Write-Verbose "[Remove-xAzDoPermission] Started."

    # Define a hashtable to store parameters for the Invoke-AzDevOpsApiRestMethod function.
    $params = @{
        # Construct the Uri using string formatting with the -f operator.
        # It includes the API endpoint, group identity, member identity, and the API version.
        Uri = "https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?tokens={2}&recurse=False&api-version={3}" -f  $OrganizationName,
                                                                                                                    $SecurityNamespaceID,
                                                                                                                    $TokenName,
                                                                                                                    $ApiVersion
        # Set the method to DELETE.
        Method = 'DELETE'
    }


    try {
        # Call the Invoke-AzDevOpsApiRestMethod function with the parameters defined above.
        # The "@" symbol is used to pass the hashtable as splatting parameters.
        Write-Verbose "[Remove-xAzDoPermission] Attempting to invoke REST method to remove ACLs."
        $member = Invoke-AzDevOpsApiRestMethod @params
        if ($member -ne $true) {
            Write-Error "[Remove-xAzDoPermission] Failed to remove ACLs."
        } else {
            Write-Verbose "[Remove-xAzDoPermission] ACLs removed successfully."
        }

    } catch {
        # If an exception occurs, write an error message to the console with details about the issue.
        Write-Error "[Remove-xAzDoPermission] Failed to add member to group: $($_.Exception.Message)"
    }


}
