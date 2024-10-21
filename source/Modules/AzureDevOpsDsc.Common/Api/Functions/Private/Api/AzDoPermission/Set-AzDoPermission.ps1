<#
.SYNOPSIS
Sets Azure DevOps permissions by invoking a REST API method.

.DESCRIPTION
The Set-AzDoPermission function sets permissions in Azure DevOps by sending a POST request to the specified API endpoint.
It constructs the URI using the organization name, security namespace ID, and API version. The function serializes the
Access Control Lists (ACLs) and sends them in the body of the request.

.PARAMETER OrganizationName
The name of the Azure DevOps organization.

.PARAMETER SecurityNamespaceID
The ID of the security namespace.

.PARAMETER SerializedACLs
The serialized Access Control Lists (ACLs) to be set.

.PARAMETER ApiVersion
The version of the Azure DevOps API to use. Defaults to the value returned by Get-AzDevOpsApiVersion -Default.

.EXAMPLE
Set-AzDoPermission -OrganizationName "MyOrg" -SecurityNamespaceID "12345" -SerializedACLs $acls

This example sets the permissions for the specified organization and security namespace using the provided ACLs.

.NOTES
The function uses the Invoke-AzDevOpsApiRestMethod to send the request. If an error occurs during the request,
an error message is written to the console.
#>

Function Set-AzDoPermission
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrganizationName,

        [Parameter(Mandatory = $true)]
        [string]$SecurityNamespaceID,

        [Parameter(Mandatory = $true)]
        [Object]$SerializedACLs,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    Write-Verbose "[Set-AzDoPermission] Started."

    # Define a hashtable to store parameters for the Invoke-AzDevOpsApiRestMethod function.

    $params = @{
        <#
            Construct the Uri using string formatting with the -f operator.
            It includes the API endpoint, group identity, member identity, and the API version.
        #>
        Uri = 'https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?api-version={2}' -f   $OrganizationName,
                                                                                            $SecurityNamespaceID,
                                                                                            $ApiVersion
        # Set the method to PUT.
        Method = 'POST'
        # Set the body of the request to the serialized ACLs.
        Body = $SerializedACLs | ConvertTo-Json -Depth 4
    }

    Write-Verbose "[Set-AzDoPermission] Body: $($params.Body)"

    try
    {
        <#
            Call the Invoke-AzDevOpsApiRestMethod function with the parameters defined above.
            The "@" symbol is used to pass the hashtable as splatting parameters.
        #>
        Write-Verbose "[Set-AzDoPermission] Attempting to invoke REST method to set ACLs."
        $null = Invoke-AzDevOpsApiRestMethod @params

    }
    catch
    {
        # If an exception occurs, write an error message to the console with details about the issue.
        Write-Error "[Set-AzDoPermission] Failed to set ACLs: $($_.Exception.Message)"
    }

}
