function Set-AccessControlList {
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
        [string]$PersonalAccessToken,

        [Parameter(Mandatory=$true)]
        [string]$AclJson
    )

    # Base64-encodes the Personal Access Token (PAT)
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    # Construct the URL for the API request
    $url = "https://dev.azure.com/$Organization/_apis/accesscontrolentries/$SecurityNamespaceId?api-version=$ApiVersion"

    try {
        # Convert the JSON string to a JSON body object
        $body = ConvertFrom-Json -InputObject $AclJson

        # Make the HTTP POST request
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Body ($body | ConvertTo-Json -Depth 10)

        # Output the response
        Write-Output "Access Control List set successfully."
        Write-Output $response
    }
    catch {
        Write-Error "Failed to set Access Control List: $_"
    }
}
