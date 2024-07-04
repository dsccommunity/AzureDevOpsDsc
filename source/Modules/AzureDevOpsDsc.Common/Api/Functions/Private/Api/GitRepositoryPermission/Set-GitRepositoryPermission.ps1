<#
.SYNOPSIS
Sets the permissions for a Git repository in Azure DevOps.

.DESCRIPTION
The Set-GitRepositoryPermission function is used to set the permissions for a Git repository in Azure DevOps. It makes a REST API call to the Azure DevOps API to update the access control lists (ACLs) for the specified repository.

.PARAMETER OrganizationName
The name of the Azure DevOps organization.

.PARAMETER SecurityNamespaceID
The ID of the security namespace for the repository.

.PARAMETER SerializedACLs
The serialized ACLs to be set for the repository.

.PARAMETER ApiVersion
The version of the Azure DevOps API to use. If not specified, the default API version will be used.

.EXAMPLE
Set-GitRepositoryPermission -OrganizationName "MyOrganization" -SecurityNamespaceID "MySecurityNamespace" -SerializedACLs $serializedACLs

This example sets the permissions for a Git repository in the "MyOrganization" Azure DevOps organization using the specified security namespace ID and serialized ACLs.

.NOTES
For more information about Azure DevOps REST API, see the official documentation:
- Access Control Lists: https://docs.microsoft.com/en-us/rest/api/azure/devops/access%20control%20lists
- Git Repositories: https://docs.microsoft.com/en-us/rest/api/azure/devops/git/repositories
#>

Function Set-GitRepositoryPermission
{
    param(
        [Parameter(Mandatory)]
        [string]$OrganizationName,

        [Parameter(Mandatory)]
        [string]$SecurityNamespaceID,

        [Parameter(Mandatory)]
        [Object]$SerializedACLs,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    Write-Verbose "[Set-GitRepositoryPermission] Started."

    # Define a hashtable to store parameters for the Invoke-AzDevOpsApiRestMethod function.

    $params = @{
        # Construct the Uri using string formatting with the -f operator.
        # It includes the API endpoint, group identity, member identity, and the API version.
        Uri = "https://dev.azure.com/{0}/_apis/accesscontrollists/{1}?api-version={2}" -f   $OrganizationName,
                                                                                            $SecurityNamespaceID,
                                                                                            $ApiVersion
        # Set the method to PUT.
        Method = 'POST'
        # Set the body of the request to the serialized ACLs.
        Body = $SerializedACLs | ConvertTo-Json
    }

    try {
        # Call the Invoke-AzDevOpsApiRestMethod function with the parameters defined above.
        # The "@" symbol is used to pass the hashtable as splatting parameters.
        Write-Verbose "[Set-GitRepositoryPermission] Attempting to invoke REST method to set ACLs."
        $null = Invoke-AzDevOpsApiRestMethod @params

    } catch {
        # If an exception occurs, write an error message to the console with details about the issue.
        Write-Error "[Set-GitRepositoryPermission] Failed to set ACLs: $($_.Exception.Message)"
    }

}
