<#
.SYNOPSIS
Removes a member from an Azure DevOps group.

.DESCRIPTION
The Remove-DevOpsGroupMember function removes a specified member from a specified Azure DevOps group using the Azure DevOps REST API.

.PARAMETER GroupIdentity
The identity of the group from which the member will be removed. This parameter is mandatory.

.PARAMETER MemberIdentity
The identity of the member to be removed from the group. This parameter is mandatory.

.PARAMETER ApiVersion
The version of the Azure DevOps API to use. If not specified, the default version is obtained from the Get-AzDevOpsApiVersion function.

.PARAMETER ApiUri
The base URI for the Azure DevOps API. This parameter is mandatory.

.EXAMPLE
Remove-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri "https://dev.azure.com/organization"

This example removes the specified member from the specified group in the Azure DevOps organization.

.NOTES
This function constructs the appropriate URI for the Azure DevOps REST API call and uses the Invoke-AzDevOpsApiRestMethod function to perform the removal operation. If the operation fails, an error message is written to the console.
#>
Function Remove-DevOpsGroupMember
{
    [CmdletBinding()]
    param
    (
        # The group Identity
        [Parameter(Mandatory = $true)]
        [Alias('Group')]
        [Object]$GroupIdentity,

        # The group member
        [Parameter(Mandatory = $true)]
        [Alias('Member')]
        [Object]$MemberIdentity,

        # Optional parameter for the API version with a default value obtained from the Get-AzDevOpsApiVersion function
        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default),

        # The URI for the Azure DevOps API.
        [Parameter(Mandatory = $true)]
        [string]
        $ApiUri
    )

    # Define a hashtable to store parameters for the Invoke-AzDevOpsApiRestMethod function.
    $params = @{
        # Construct the Uri using string formatting with the -f operator.
        # It includes the API endpoint, group identity, member identity, and the API version.
        Uri = '{0}/_apis/graph/memberships/{1}/{2}?api-version={3}' -f  $ApiUri,
                                                                        $MemberIdentity.descriptor,
                                                                        $GroupIdentity.descriptor,
                                                                        $ApiVersion
        # Specifies the HTTP method to be used in the REST call, in this case 'PUT'.
        Method = 'DELETE'
    }

    Write-Verbose "[Remove-DevOpsGroupMember] Constructed URI for REST call: $($params.Uri)"

    # Try to invoke the REST method to create the group and return the result

    try
    {
        # Call the Invoke-AzDevOpsApiRestMethod function with the parameters defined above.
        # The "@" symbol is used to pass the hashtable as splatting parameters.
        Write-Verbose "[Remove-DevOpsGroupMember] Attempting to invoke REST method to remove group member."
        $member = Invoke-AzDevOpsApiRestMethod @params
        Write-Verbose "[Remove-DevOpsGroupMember] Member removed successfully."

    }
    catch
    {
        # If an exception occurs, write an error message to the console with details about the issue.
        Write-Error "[Remove-DevOpsGroupMember] Failed to add member to group: $($_.Exception.Message)"
    }

}
