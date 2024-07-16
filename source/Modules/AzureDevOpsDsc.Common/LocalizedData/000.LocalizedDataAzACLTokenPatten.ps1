data LocalizedDataAzACLTokenPatten
{
@'

#
# Git ACL Token Patterns
#

# Organizational Level Token
OrganizationGit = ^repoV2$
# Project-Level Git Repository Token
GitProject = \^\(repoV2\)\\/\(\?<ProjectId>\[A-Za-z0-9-]\+\)\$
# Git Repository Token
GitRepository = \^\(repoV2\)\\/\(\?<ProjectId>\[A-Za-z0-9-]\+\)\\/\(\?<RepoId>\[A-Za-z0-9-]\+\)\$
# Git Branch Token
GitBranch = \^\(repoV2\)\\/\(\?<ProjectId>\[A-Za-z0-9-]\+\)\\/\(\?<RepoId>\[A-Za-z0-9-]\+\)\\/refs\\/heads\\/\(\?<BranchName>\[A-Za-z0-9]\+\)\$

#
# Identity ACL Token Patterns
#

# Group Permission Token
GroupPermission = ^(?<ProjectId>[A-Za-z0-9-_]+)\\{2}(?<GroupId>[A-Za-z0-9-_]+)$
# Resource (Project or Identity) Permission
ResourcePermission = \^\(\?<ProjectId>\[A-Za-z0-9-_]\+\)\$

'@ | ConvertFrom-StringData
}
