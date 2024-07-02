Function Remove-DevOpsGroupMember {
    [CmdletBinding()]
    param
    (
        # The group Identity
        [Parameter(Mandatory)]
        [Alias('Group')]
        [Object]$GroupIdentity,

        # The group member
        [Parameter(Mandatory)]
        [Alias('Member')]
        [Object]$MemberIdentity,

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
        Uri = "{0}/_apis/graph/memberships/{1}/{2}?api-version={3}" -f  $ApiUri,
                                                                        $MemberIdentity.descriptor,
                                                                        $GroupIdentity.descriptor,
                                                                        $ApiVersion
        # Specifies the HTTP method to be used in the REST call, in this case 'PUT'.
        Method = 'DELETE'
    }

    Write-Verbose "[Remove-DevOpsGroupMember] Constructed URI for REST call: $($params.Uri)"

    # Try to invoke the REST method to create the group and return the result

    try {
        # Call the Invoke-AzDevOpsApiRestMethod function with the parameters defined above.
        # The "@" symbol is used to pass the hashtable as splatting parameters.
        Write-Verbose "[Remove-DevOpsGroupMember] Attempting to invoke REST method to remove group member."
        $member = Invoke-AzDevOpsApiRestMethod @params
        Write-Verbose "[Remove-DevOpsGroupMember] Member removed successfully."

    } catch {
        # If an exception occurs, write an error message to the console with details about the issue.
        Write-Error "[Remove-DevOpsGroupMember] Failed to add member to group: $($_.Exception.Message)"
    }

    Write-Verbose "[Remove-DevOpsGroupMember] Result $($member | ConvertTo-Json)."

    # Return the result of the REST method invocation, which is stored in $member.
    Write-Verbose "[Remove-DevOpsGroupMember] Returning result from REST method invocation."
    return $member


}
