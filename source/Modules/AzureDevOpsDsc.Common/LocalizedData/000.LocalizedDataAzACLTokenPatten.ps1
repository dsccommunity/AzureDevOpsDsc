<#
.SYNOPSIS
    Contains localized data for Azure DevOps ACL token patterns.

.DESCRIPTION
    This data section defines various regular expression patterns used for matching Azure DevOps ACL tokens.
    These patterns are used to identify and extract information from different components such as organizations,
    projects, repositories, branches, groups, and resources within Azure DevOps.

.KEYWORDS
    Azure DevOps, ACL, Token Patterns, Regular Expressions

.EXAMPLES
    The patterns can be used to match and extract information from ACL tokens in Azure DevOps:

    - OrganizationGit: Matches the organization token.
    - GitProject: Matches the project token and extracts the ProjectId.
    - GitRepository: Matches the repository token and extracts the ProjectId and RepoId.
    - GitBranch: Matches the branch token and extracts the ProjectId, RepoId, and BranchName.
    - GroupPermission: Matches the group permission token and extracts the ProjectId and GroupId.
    - ResourcePermission: Matches the resource permission token and extracts the ProjectId.
#>
data LocalizedDataAzACLTokenPatten
{
    @{
        # Git ACL Token Patterns
        OrganizationGit     = '^repoV2$'
        GitProject          = '^(repoV2)\/(?<ProjectId>[A-Za-z0-9-]+)$'
        GitRepository       = '^(repoV2)\/(?<ProjectId>[A-Za-z0-9-]+)\/(?<RepoId>[A-Za-z0-9-]+)$'
        GitBranch           = '^(repoV2)\/(?<ProjectId>[A-Za-z0-9-]+)\/(?<RepoId>[A-Za-z0-9-]+)\/refs\/heads\/(?<BranchName>[A-Za-z0-9]+)'
        # Identity ACL Token Patterns
        GroupPermission     = '^(?<ProjectId>[A-Za-z0-9-_]+)\\(?<GroupId>[A-Za-z0-9-_]+)$'
        ResourcePermission  = '^(?<ProjectId>[A-Za-z0-9-_]+)$'
    }
}
