function Set-AzDevOpsApiACE {
    param (
        [string]$Organization,
        [string]$Project, # Optional: specify if the security namespace is scoped to a project
        [string]$SecurityNamespaceId,
        [string]$Token,
        [string]$Descriptor,
        [int]$Allow,
        [int]$Deny,
        [string]$PersonalAccessToken
    )

    # Construct the URL for the API call
    $projectSegment = if ($Project) { "/$Project" } else { "" }
    $url = "https://dev.azure.com/$Organization$projectSegment/_apis/accesscontrolentries/$SecurityNamespaceId?api-version=7.2"

    # Create the JSON body of the request
    $body = @{
        token = $Token
        merge = $true
        accessControlEntries = @(
            @{
                descriptor = $Descriptor
                allow      = $Allow
                deny       = $Deny
            }
        )
    } | ConvertTo-Json

    # Set up the headers with the Personal Access Token for authentication
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
    $headers = @{
        Authorization = "Basic $base64AuthInfo"
        Content-Type  = "application/json"
    }

    try {
        # Perform the HTTP POST request
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ContentType "application/json"

        # Output the response
        Write-Output "Access control entries set successfully."
        Write-Output $response
    }
    catch {
        # Handle errors
        Write-Error "Failed to set access control entries. Error: $_"
    }
}

# Usage example:
# Set-AccessControlEntries -Organization "your-organization" -SecurityNamespaceId "your-security-namespace-id" -Token "security-token" -Descriptor "user-descriptor" -Allow 1 -Deny 2 -PersonalAccessToken "your-PAT"
