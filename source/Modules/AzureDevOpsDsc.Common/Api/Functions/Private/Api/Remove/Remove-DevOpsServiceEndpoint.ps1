function Remove-DevOpsServiceEndpoint {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Organization,

        [Parameter(Mandatory = $true)]
        [string]$ProjectId,

        [Parameter(Mandatory = $true)]
        [string]$PersonalAccessToken,

        [Parameter(Mandatory = $true)]
        [string]$ServiceEndpointId
    )

    $encodedPAT = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PersonalAccessToken)"))

    $uri = "https://dev.azure.com/$Organization/$ProjectId/_apis/serviceendpoint/endpoints/$ServiceEndpointId?api-version=7.2-preview.1"

    try {
        $headers = @{
            Authorization = "Basic $encodedPAT"
            'Content-Type' = 'application/json'
        }

        Invoke-RestMethod -Uri $uri -Headers $headers -Method Delete

        Write-Output "Service endpoint with ID $ServiceEndpointId deleted successfully."
    } catch {
        Write-Error "Failed to delete service endpoint: $_"
    }
}
