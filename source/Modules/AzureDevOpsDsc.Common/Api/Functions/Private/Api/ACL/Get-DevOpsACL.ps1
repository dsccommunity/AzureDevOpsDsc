<#
function Get-AzDevOpsACL
{
    param (
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [String]$SecruityDescriptorType,

        [Parameter(Mandatory)]


    )




    param (
        [Parameter(Mandatory=$true)]
        [string]$Organization,
        [Parameter(Mandatory=$true)]
        [string]$ProjectName, # Optional: specify if the security namespace is scoped to a project
        [string]$SecurityNamespaceId,
        [string]$Token, # Optional: specify if you want to filter ACLs for a specific token
        [string]$Descriptors, # Optional: comma-separated list of descriptors to filter
        [bool]$IncludeExtendedInfo = $false, # Optional: set to $true to include extended info
        [bool]$Recurse = $false, # Optional: set to $true to recurse and get all children
        [string]$PersonalAccessToken
    )

    $params = @{

    }









    # Construct the URL for the API call
    $projectSegment = if ($Project) { "/$Project" } else { "" }
    $url = "https://dev.azure.com/$Organization$projectSegment/_apis/accesscontrolentries/$SecurityNamespaceId"

    # Add query parameters
    $queryParams = @{
        'api-version' = '7.2'
        'token'       = $Token
        'descriptors' = $Descriptors
        'includeExtendedInfo' = $IncludeExtendedInfo
        'recurse'     = $Recurse
    }

    $queryString = ($queryParams.GetEnumerator() | Where-Object { $_.Value }) |
                   ForEach-Object { "$($_.Key)=$($_.Value)" } |
                   Join-String -Separator '&'

    $urlWithQuery = "$url?$queryString"

    # Set up the headers with the Personal Access Token for authentication
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))
    $headers = @{
        Authorization = "Basic $base64AuthInfo"
    }

    try {
        # Perform the HTTP GET request
        $response = Invoke-RestMethod -Uri $urlWithQuery -Method Get -Headers $headers

        # Output the response
        Write-Output "Access control lists retrieved successfully."
        Write-Output $response
    }
    catch {
        # Handle errors
        Write-Error "Failed to retrieve access control lists. Error: $_"
    }
}

# Usage example:
# Get-AccessControlLists -Organization "your-organization" -SecurityNamespaceId "your-security-namespace-id" -PersonalAccessToken "your-PAT"

#>
