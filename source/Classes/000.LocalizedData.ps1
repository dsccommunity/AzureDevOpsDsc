data LocalizedDataAzTokenPatten
{
@'
# Project-Level Token
Project = ^\$PROJECT:vstfs:\/\/\/Classification\/TeamProject\/(?<ProjectId>[a-zA-Z0-9\-]+)$
# Project-Level Git Repository Token
ProjectLevelGitRepository = (^repoV2)\/(?<ProjectId>[A-Za-z0-9-]+)$
# Git Repository Token
GitRepository = (^repoV2)\/(?<ProjectId>[A-Za-z0-9-]+)\/(?<RepoId>[A-Za-z0-9-]+)$
'@ | ConvertFrom-StringData
}
