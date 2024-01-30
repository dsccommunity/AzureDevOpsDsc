function Remove-AzDevOpsApiACL {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Organization,

        [Parameter(Mandatory=$true)]
        [string]$Project,

        [Parameter(Mandatory=$true)]
        [string]$SecurityNamespaceId,

        [Parameter(Mandatory=$true)]
        [string]$Token,

        [Parameter(Mandatory=$true)]
        [string]$ApiVersion = "7.2",

        [Parameter(Mandatory=$true)]
        [string]$PersonalAccessToken
    )

    # Base64-encodes the Personal Access Token (PAT)
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    # Construct the URL for the API request
    $url = "https://dev.azure.com/$Organization/_apis/accesscontrolentries/$SecurityNamespaceId?token=$Token&api-version=$ApiVersion"

    try {
        # Make the HTTP DELETE request
        $response = Invoke-RestMethod -Uri $url -Method Delete -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json"

        # Output the response
        Write-Output "Access Control List removed successfully."
        Write-Output $response
    }
    catch {
        Write-Error "Failed to remove Access Control List: $_"
    }
}
