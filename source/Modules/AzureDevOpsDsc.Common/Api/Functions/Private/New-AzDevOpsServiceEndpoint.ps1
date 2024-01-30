function New-AzDevOpsServiceEndpoint {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken,

        [Parameter(Mandatory = $true)]
        [string]$ServiceEndpointName,

        [Parameter(Mandatory = $true)]
        [string]$ServiceEndpointType,

        [Parameter(Mandatory = $true)]
        [hashtable]$ServiceEndpointDetails
    )

    $encodedPAT = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $uri = "https://dev.azure.com/$Organization/$ProjectId/_apis/serviceendpoint/endpoints?api-version=7.2-preview.1"

    $body = @{
        name = $ServiceEndpointName
        type = $ServiceEndpointType
        url = $ServiceEndpointDetails.url
        authorization = @{
            scheme = $ServiceEndpointDetails.scheme
            parameters = $ServiceEndpointDetails.parameters
        }
    } | ConvertTo-Json

    try {
        $headers = @{
            Authorization = "Basic $encodedPAT"
            'Content-Type' = 'application/json'
        }

        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $body

        Write-Output "Service endpoint created successfully."
        return $response
    } catch {
        Write-Error "Failed to create service endpoint: $_"
    }
}
