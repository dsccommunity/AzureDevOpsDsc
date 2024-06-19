Function Get-DevOpsACLList {

    param(
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [String]$SecruityDescriptorType,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    #
    # Perform a lookup of the security descriptor types for the organization
    $descriptor = Get-CacheItem -Key $SecruityDescriptorType -Type 'SecurityNamespaces'

    # If the descriptor is not found, return an error
    if (-not $descriptor) {
        Write-Error "The security descriptor type '$SecruityDescriptorType' was not found."
    }

    # Construct the URL for the API call
    $params = @{
        Uri = "https://dev.azure.com/{0}/_apis/accesscontrollists/{1}" -f $OrganizationName, $descriptor.namespaceId
        Method = 'Get'
    }

    # Invoke the REST API call

    #
    # Perform a lookup to get the group

    $ACLs = Invoke-AzDevOpsRestApi @params

    if ($null -eq $ACLs.value) {
        return $null
    }

    #
    # Return the groups from the cache
    return $ACLs.value

}
