<#
.SYNOPSIS
Converts a security identity to an ACL token based on the security namespace.

.DESCRIPTION
The ConvertTo-ACLToken function converts a security identity to an ACL token based on the specified security namespace. It is used in the Azure DevOps DSC module to derive the token type and other relevant information for Git repositories.

.PARAMETER SecurityNamespace
Specifies the security namespace for which the ACL token needs to be generated.

.PARAMETER Identity
Specifies the security identity that needs to be converted to an ACL token.

.OUTPUTS
The function returns a hashtable containing the following properties:
- type: The type of the ACL token (e.g., GitOrganization, GitProject, GitRepository, GitUnknown, UnknownSecurityNamespace).
- inherited: Indicates whether the security identity is inherited or not.
- projectId: The ID of the project associated with the ACL token (applicable for GitProject and GitRepository types).
- RepoId: The ID of the repository associated with the ACL token (applicable for GitRepository type).

.EXAMPLE
ConvertTo-ACLToken -SecurityNamespace 'Git Repositories' -Identity 'Contoso/Org/Project'

This example converts the security identity 'Contoso/Org/Project' to an ACL token for the 'Git Repositories' security namespace. The resulting ACL token will have the type 'GitProject' and the project ID will be retrieved from the cache.

.NOTES
This function is part of the AzureDevOpsDsc.Common module and is used internally by other functions in the module.
#>

Function ConvertTo-ACLToken {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$SecurityNamespace,

        [Parameter(Mandatory)]
        [string]$Identity

    )

    Write-Verbose "[ConvertTo-ACLToken] Started."

    $result = @{}

    # Create a new ACL Object
    switch ($SecurityNamespace) {

        # Git Repositories
        'Git Repositories' {

            # Derive the Token Type GitOrganization, GitProject or GitRepository
            if ($Identity -match $LocalizedDataAzResourceTokenPatten.OrganizationGit) {
                # Derive the Token Type GitOrganization
                $result.type = 'GitOrganization'

            } elseif ($Identity -match $LocalizedDataAzResourceTokenPatten.GitProject) {
                # Derive the Token Type GitProject
                $result.type = 'GitProject'
                $result.projectId = (Get-CacheItem -Key $matches.ProjectName.Trim() -Type 'Projects').id

            } elseif ($Identity -match $LocalizedDataAzResourceTokenPatten.GitRepository) {
                # Derive the Token Type GitRepository
                $result.type = 'GitRepository'
                $result.projectId = (Get-CacheItem -Key $matches.ProjectName.Trim() -Type 'Projects').id
                $result.RepoId = (Get-CacheItem -Key $Identity -Type 'LiveRepositories').id

            } else {
                # Derive the Token Type GitUnknown
                $result.type = 'GitUnknown'
                Write-Warning "[ConvertTo-ACLToken] Identity '$Identity' does not match any known Git ACL Token Patterns."
            }
            break;
        }

        default {
            Write-Warning "[ConvertTo-ACLToken] SecurityNamespace '$SecurityNamespace' is not recognized."
            $result.type = 'UnknownSecurityNamespace'
        }

    }

    # Return the ACL Token
    return $result

}
