<#
.SYNOPSIS
Creates a cache for Azure DevOps API response.

.DESCRIPTION
The New-AzDevOpsApiCache function creates a cache for Azure DevOps API response. It saves the API response content to a cache file and creates a metadata file with information about the API endpoint, parameters, cache file, and timestamp.

.PARAMETER ApiEndpoint
The API endpoint for which the cache is being created.

.PARAMETER Parameters
The parameters used in the API request.

.PARAMETER Content
The content of the API response.

.PARAMETER Depth
The depth to which the content should be converted to JSON. Default value is 2.

.EXAMPLE
$content = @{ key1 = 'value1'; key2 = 'value2' }
New-AzDevOpsApiCache -ApiEndpoint 'projects/list' -Parameters @{ organization = 'myOrg' } -Content $content

.NOTES
Author: Your Name
Date: Current Date
#>
function New-AzDevOpsApiCache {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ApiEndpoint,

        [Parameter(Mandatory)]
        [hashtable]$Parameters,

        [Parameter(Mandatory)]
        [object]$Content,

        [Parameter()]
        [int]$Depth = 2
    )

    try {
        # Rest of the code...
    } catch {
        throw "Failed to create cache for Azure DevOps API: $_"
    }
}
function New-AzDevOpsApiCache {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ApiEndpoint,

        [Parameter(Mandatory)]
        [hashtable]$Parameters,

        [Parameter(Mandatory)]
        [object]$Content,

        [Parameter()]
        [int]$Depth = 2
    )

    try {

        # Ensure the AZDODSCCachePath environment variable exists
        if (-not $ENV:AZDODSCCachePath) {
            throw "AZDODSCCachePath environment variable is not set."
        }

        # Create the AZDODSCCachePath directory if it doesn't exist
        $AZDODSCCachePath = $ENV:AZDODSCCachePath
        if (-not (Test-Path -Path $AZDODSCCachePath)) {
            $null = New-Item -ItemType Directory -Path $AZDODSCCachePath
        }

        # Normalize the API endpoint to use as part of the filename
        $normalizedApiEndpoint = $ApiEndpoint -replace '[\/:\*\?"<>|]', '_'

        # Construct cache file names
        $cacheFileName = "{0}_{1}.json" -f $normalizedApiEndpoint, [GUID]::NewGuid().ToString()
        $metadataFileName = "{0}_{1}.metadata.json" -f $normalizedApiEndpoint, [GUID]::NewGuid().ToString()

        # Paths for the cache and metadata files
        $cacheFilePath = Join-Path -Path $AZDODSCCachePath -ChildPath $cacheFileName
        $metadataFilePath = Join-Path -Path $AZDODSCCachePath -ChildPath $metadataFileName

        # Convert the content to JSON
        $jsonContent = $Content | ConvertTo-Json -Depth $Depth

        # Save the content to the cache file
        $jsonContent | Out-File -FilePath $cacheFilePath -Encoding UTF8

        # Create metadata object
        $metadataObject = @{
            ApiEndpoint = $ApiEndpoint
            Parameters = $Parameters
            CacheFile = $cacheFileName
            Timestamp = Get-Date -Format 'o' # ISO 8601 format
        }

        # Save the metadata to the metadata file
        $metadataObject | ConvertTo-Json | Out-File -FilePath $metadataFilePath -Encoding UTF8

        Write-Verbose "Cache and metadata created successfully."

    } catch {
        throw "Failed to create cache for Azure DevOps API: $_"
    }

}

# Example usage:
# $content = @{ key1 = 'value1'; key2 = 'value2' }
# New-AzDevOpsApiCache -ApiEndpoint 'projects/list' -Parameters @{ organization = 'myOrg' } -Content $content
