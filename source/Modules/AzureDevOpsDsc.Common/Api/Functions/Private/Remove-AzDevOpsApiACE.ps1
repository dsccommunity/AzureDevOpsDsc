function Remove-AzDevOpsApiACE {
    param (
        [string]$Organization,
        [string]$SecurityNamespaceId,
        [string]$Token,
        [string]$PersonalAccessToken
    )

    # Construct the URL for the API call
    $url = "https://dev.azure.com/$Organization/_apis/accesscontrolentries/$SecurityNamespaceId?token=$Token&api-version=7.2"

    # Set up the headers with the Personal Access Token for authentication
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
    $headers = @{
        Authorization = "Basic $base64AuthInfo"
    }

    try {
        # Perform the HTTP DELETE request
        $response = Invoke-RestMethod -Uri $url -Method Delete -Headers $headers -ContentType "application/json"

        # Output the response
        Write-Output "Access control entries removed successfully."
        Write-Output $response
    }
    catch {
        # Handle errors
        Write-Error "Failed to remove access control entries. Error: $_"
    }
}

# Usage example:
# Remove-AccessControlEntries -Organization "your-organization" -SecurityNamespaceId "your-security-namespace-id" -Token "descriptor-for-the-ACEs-to-remove" -PersonalAccessToken "your-PAT"
