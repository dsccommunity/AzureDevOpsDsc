data LocalizedDataAzSerilizationPatten
{
@'

# Git Repository ACL Token Patterns. Exclude the refs token since these are branch level ACLs.
# Example: repoV2/ProjectId/RepoId
# Not: repoV2/ProjectId/RepoId/refs/heads/BranchName
GitRepository = \^repoV2\\/\{0}\\/\(\?!\.\*\\/refs\)\.\*

'@ | ConvertFrom-StringData
}
