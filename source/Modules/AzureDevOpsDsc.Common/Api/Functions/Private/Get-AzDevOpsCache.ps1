<#
.SYNOPSIS
Retrieves the cache content for a specific Azure DevOps API endpoint.

.DESCRIPTION
The Get-AzDevOpsApiCache function retrieves the cache content for a specific Azure DevOps API endpoint. It checks if there is a cache file available for the given API endpoint and parameters, and returns the cache content if it exists.

.PARAMETER ApiEndpoint
The API endpoint for which to retrieve the cache content.

.PARAMETER Parameters
The parameters used for the API endpoint.

.EXAMPLE
$apiEndpoint = "https://dev.azure.com/myorganization/myproject/_apis/build/builds"
$parameters = @{
    'definitionId' = 1234
    'status' = 'completed'
}
$cacheContent = Get-AzDevOpsApiCache -ApiEndpoint $apiEndpoint -Parameters $parameters

.NOTES
This function requires the AZDODSCCachePath environment variable to be set. The cache files are stored in the directory specified by the AZDODSCCachePath environment variable.
#>
function Get-AzDevOpsApiCache {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ApiEndpoint,

        [Parameter(Mandatory)]
        [hashtable]$Parameters
    )

    try {
        # Ensure the AZDODSCCachePath environment variable exists
        if (-not $ENV:AZDODSCCachePath) {
            throw "AZDODSCCachePath environment variable is not set."
        }

        # Normalize the API endpoint to use as part of the filename
        $normalizedApiEndpoint = $ApiEndpoint -replace '[\/:\*\?"<>|]', '_'

        # Create a pattern for the metadata file name based on the API endpoint
        $metadataFilePattern = Join-Path -Path $ENV:AZDODSCCachePath -ChildPath "${normalizedApiEndpoint}_*.metadata.json"

        # Find the metadata file
        $metadataFiles = Get-ChildItem -Path $metadataFilePattern

        # If no metadata files found, return $null indicating there is no cache
        if ($metadataFiles.Count -eq 0) {
            return $null
        }

        # Assuming we want the latest cache, sort by LastWriteTime and select the first one
        $latestMetadataFile = $metadataFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1

        # Read the metadata file content
        $metadataContent = Get-Content -Path $latestMetadataFile.FullName -Raw | ConvertFrom-Json

        # Check if the parameters match
        $cachedParameters = $metadataContent.Parameters
        $match = $true
        foreach ($key in $Parameters.Keys) {
            if ($Parameters[$key] -ne $cachedParameters[$key]) {
                $match = $false
                break
            }
        }

        # If the parameters don't match, return $null indicating there is no cache
        if (-not $match) { return $null }

        # Construct the cache file path from the metadata
        $cacheFilePath = Join-Path -Path $ENV:AZDODSCCachePath -ChildPath $metadataContent.CacheFile

        # Read the cache file content
        $cacheContent = Get-Content -Path $cacheFilePath -Raw | ConvertFrom-Json

        # Return the cache content
        return $cacheContent

    } catch {
        throw "Failed to get cache for Azure DevOps API: $_"
    }
}
