<#
.SYNOPSIS
    Adds a member to an Azure DevOps group using the Azure DevOps REST API.

.DESCRIPTION
    The New-DevOpsGroupMember function adds a specified member to a specified Azure DevOps group by invoking the Azure DevOps REST API.
    It constructs the appropriate URI for the API call and uses the 'PUT' method to add the member to the group.

.PARAMETER GroupIdentity
    The identity of the group to which the member will be added. This parameter is mandatory.

.PARAMETER MemberIdentity
    The identity of the member to be added to the group. This parameter is mandatory.

.PARAMETER ApiVersion
    The version of the Azure DevOps API to use. If not specified, the default value is obtained from the Get-AzDevOpsApiVersion function.

.PARAMETER ApiUri
    The URI for the Azure DevOps API. This parameter is mandatory.

.EXAMPLE
    $group = Get-DevOpsGroup -Name "Developers"
    $member = Get-DevOpsUser -UserName "jdoe"
    New-DevOpsGroupMember -GroupIdentity $group -MemberIdentity $member -ApiUri "https://dev.azure.com/yourorganization"

    This example adds the user "jdoe" to the "Developers" group in the specified Azure DevOps organization.

.NOTES
    The function uses the Invoke-AzDevOpsApiRestMethod function to perform the REST API call.
    It handles exceptions by writing an error message to the console if the API call fails.
#>
Function New-DevOpsGroupMember
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
        Method = 'PUT'
    }

    Write-Verbose "[Add-DevOpsGroupMember] Constructed URI for REST call: $($params.Uri)"

    # Try to invoke the REST method to create the group and return the result

    try
    {
        # Call the Invoke-AzDevOpsApiRestMethod function with the parameters defined above.
        # The "@" symbol is used to pass the hashtable as splatting parameters.
        Write-Verbose "[Add-DevOpsGroupMember] Attempting to invoke REST method to add group member."
        $member = Invoke-AzDevOpsApiRestMethod @params
        Write-Verbose "[Add-DevOpsGroupMember] Member added successfully."
    }
    catch
    {
        # If an exception occurs, write an error message to the console with details about the issue.
        Write-Error "[Add-DevOpsGroupMember] Failed to add member to group: $($_.Exception.Message)"
    }

    Write-Verbose "[Add-DevOpsGroupMember] Result $($member | ConvertTo-Json)."

    # Return the result of the REST method invocation, which is stored in $member.
    Write-Verbose "[Add-DevOpsGroupMember] Returning result from REST method invocation."
    return $member

}
