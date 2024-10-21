<#
.SYNOPSIS
Removes access control lists (ACLs) for a specified token in an Azure DevOps organization.

.DESCRIPTION
The Remove-AzDoPermission function removes ACLs for a specified token within a given security namespace in an Azure DevOps organization. It constructs the appropriate API endpoint and invokes a REST method to delete the ACLs.

.PARAMETER OrganizationName
The name of the Azure DevOps organization.

.PARAMETER SecurityNamespaceID
The ID of the security namespace.

.PARAMETER TokenName
The name of the token for which the ACLs should be removed.

.PARAMETER ApiVersion
The version of the Azure DevOps API to use. If not specified, the default API version is used.

.EXAMPLE
Remove-AzDoPermission -OrganizationName "MyOrg" -SecurityNamespaceID "12345" -TokenName "MyToken"

This example removes the ACLs for the token "MyToken" in the security namespace with ID "12345" within the "MyOrg" organization.

.NOTES
This function uses the Invoke-AzDevOpsApiRestMethod function to perform the REST API call. Ensure that the necessary permissions are in place to delete ACLs in the specified Azure DevOps organization.

#>
Function Remove-AzDoPermission
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrganizationName,

        [Parameter(Mandatory = $true)]
        [string]$SecurityNamespaceID,

        [Parameter(Mandatory = $true)]
        [string]$TokenName,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    Write-Verbose "[Remove-AzDoPermission] Started."

    # Define a hashtable to store parameters for the Invoke-AzDevOpsApiRestMethod function.
    $params = @{
        <#
            Construct the Uri using string formatting with the -f operator.
            It includes the API endpoint, group identity, member identity, and the API version.
        #>
        Uri = 'https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?tokens={2}&recurse=False&api-version={3}' -f  $OrganizationName,
                                                                                                                    $SecurityNamespaceID,
                                                                                                                    $TokenName,
                                                                                                                    $ApiVersion
        # Set the method to DELETE.
        Method = 'DELETE'
    }

    try
    {
        <#
            Call the Invoke-AzDevOpsApiRestMethod function with the parameters defined above.
            The "@" symbol is used to pass the hashtable as splatting parameters.
        #>
        Write-Verbose "[Remove-AzDoPermission] Attempting to invoke REST method to remove ACLs."
        $member = Invoke-AzDevOpsApiRestMethod @params

        if ($member -ne $true)
        {
            Write-Error "[Remove-AzDoPermission] Failed to remove ACLs."
        }
        else
        {
            Write-Verbose "[Remove-AzDoPermission] ACLs removed successfully."
        }

    }
    catch
    {
        # If an exception occurs, write an error message to the console with details about the issue.
        Write-Error "[Remove-AzDoPermission] Failed to add member to group: $($_.Exception.Message)"
    }

}
