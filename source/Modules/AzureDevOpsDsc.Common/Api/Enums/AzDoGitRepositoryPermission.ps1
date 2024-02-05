<#
.SYNOPSIS
    Enumeration of Azure DevOps Git repository permissions.

.DESCRIPTION
    The AzDoGitRepositories enumeration defines the different permissions that can be assigned to users or groups for Azure DevOps Git repositories.

Manages Git repository permissions at the project-level and object-level. You can manage these permissions through the Project settings, Repositories administrative interface.

The Administer permission was divided into several more granular permissions in 2017, and should not be used.
Token format for project-level permissions: repoV2/PROJECT_ID
You need to append RepositoryID to update repository-level permissions.

Token format for repository-specific permissions: repoV2/PROJECT_ID/REPO_ID

ID: 2e9eb7ed-3c0a-47d4-87c1-0ffdd275fd87

.NOTES
    For more information, refer to the official Microsoft documentation:
    https://learn.microsoft.com/en-us/azure/devops/organizations/security/namespace-reference?view=azure-devops#object-level-namespaces-and-permissions
#>
Enum AzDoGitRepositoryPermission {
    Administer = 1
    GenericRead = 2
    GenericContribute = 4
    ForcePush = 8
    CreateBranch = 16
    CreateTag = 32
    ManageNote = 64
    PolicyExempt = 128
    CreateRepository = 256
    DeleteRepository = 512
    RenameRepository = 1024
    EditPolicies = 2048
    RemoteOtherLocks = 4096
    ManagePermissions = 8192
    PullRequestContribute = 16384
    PullRequestBypassPolicy = 32768
}
