Function New-DevOpsGroupMember {
    [CmdletBinding()]
    param
    (
        # The group Identity
        [Parameter(Mandatory)]
        [Alias('Group')]
        [System.String]$GroupIdentity,

        # The group member
        [Parameter(Mandatory)]
        [Alias('Member')]
        [System.String]$MemberIdentity,

        # Optional parameter for the API version with a default value obtained from the Get-AzDevOpsApiVersion function
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default),

        # The URI for the Azure DevOps API.
        [Parameter(Mandatory)]
        [string]
        $ApiUri

    )

    # Define a hashtable to store parameters for the Invoke-AzDevOpsApiRestMethod function.
    $params = @{
        # Construct the Uri using string formatting with the -f operator.
        # It includes the API endpoint, group identity, member identity, and the API version.
        Uri = "{0}/_apis/GroupEntitlements/{1}/members/{2}?api-version={3}" -f $ApiUri,
                                                                                $GroupIdentity.value.originId,
                                                                                $MemberIdentity.value.originId,
                                                                                $ApiVersion
        # Specifies the HTTP method to be used in the REST call, in this case 'PUT'.
        Method = 'PUT'
    }

    Write-Verbose "[Add-DevOpsGroupMember] Constructed URI for REST call: $($params.Uri)"

    # Try to invoke the REST method to create the group and return the result

    try {
        # Call the Invoke-AzDevOpsApiRestMethod function with the parameters defined above.
        # The "@" symbol is used to pass the hashtable as splatting parameters.
        Write-Verbose "[Add-DevOpsGroupMember] Attempting to invoke REST method to add group member."
        $member = Invoke-AzDevOpsApiRestMethod @params
        Write-Verbose "[Add-DevOpsGroupMember] Member added successfully."

    } catch {
        # If an exception occurs, write an error message to the console with details about the issue.
        Write-Error "[Add-DevOpsGroupMember] Failed to add member to group: $($_.Exception.Message)"
    }

    # Return the result of the REST method invocation, which is stored in $member.
    Write-Verbose "[Add-DevOpsGroupMember] Returning result from REST method invocation."
    return $member


}
