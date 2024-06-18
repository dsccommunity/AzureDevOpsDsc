

enum AzdoAclTokenType
{
    Project = 0
    ProjectRepository = 1
    Repository = 2
    RepositoryBranch = 3

}


class AzdoTokenIdentifier
{
    [HashTable[]]$AzdoAclTokens = @(

        # Project-Level Git Repository Token
        @{
            pattern = "(^repoV2)\/(?<ProjectId>[A-Za-z0-9\-]+)\/(?<RepoId>[A-Za-z0-9\-]+)"
            format = {
                return [PSCustomObject]@{
                    Type = [AzdoAclTokenType]::ProjectRepository
                    Project = $matches["ProjectId"]
                }
            }
        }
        # Git Repository Token
        @{
            pattern = "(^repoV2)\/(?<ProjectId>[A-Za-z0-9\-]+$)\/(?<RepoId>[A-Za-z0-9\-]+$)"
            format = {
                return [PSCustomObject]@{
                    Type = [AzdoAclTokenType]::ProjectRepository
                    Project = $matches["ProjectId"]
                }
            }
        }

    )

    #
    # Function to get the type of the token
    static [HashTable]GetType([string]$token)
    {
        $tokenObj = [AzdoTokenIdentifier]::new()

        foreach ($token in $tokenObj.AzdoAclTokens)
        {
            $pattern = $tokenObj.AzdoAclTokens[$token].pattern
            if ($token -match $pattern)
            {
                $format = $tokenObj.AzdoAclTokens[$token].format
                return $format.Invoke($matches)
            }
        }
        <#
        foreach ($type in $tokenObj.AzdoAclTokens.Keys)
        {
            $pattern = $tokenObj.AzdoAclTokens[$type].pattern
            if ($token -match $pattern)
            {
                $format = $tokenObj.AzdoAclTokens[$type].format
                return $format.Invoke($matches)
            }
        }
        #>
        return $null
    }
}
