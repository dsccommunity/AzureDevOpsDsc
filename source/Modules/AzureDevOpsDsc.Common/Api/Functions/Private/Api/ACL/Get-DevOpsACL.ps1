function Get-DevOpsACL
{
    param (
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [String]$SecurityDescriptorId,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    #
    # Construct the URL for the API call
    $params = @{
        Uri = "https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?api-version={2}" -f $OrganizationName, $SecurityDescriptorId, $ApiVersion
        Method = 'Get'
    }

    # Invoke the REST API call
    $ACLList = Invoke-AzDevOpsApiRestMethod @params

    if (($null -eq $ACLList.value) -or ($ACLList.count -eq 0))
    {
        return $null
    }

    #
    # Cache the ACL List. Use the SecurityDescriptorId as the key
    Add-CacheItem -Key $SecurityDescriptorId -Value $ACLList.value -Type 'ACLList' -Write

    return $ACLList.value

}
