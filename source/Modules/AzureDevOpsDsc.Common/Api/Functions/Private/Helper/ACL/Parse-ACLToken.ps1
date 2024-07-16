Function Parse-ACLToken {
    param(
        [Parameter(Mandatory)]
        [String]$Token,

        [Parameter(Mandatory)]
        [ValidateSet('Identity', 'Git Repositories')]
        [String]$SecurityNamespace
    )

    $result = @{}

    Write-Verbose "[Parse-ACLToken] Started."
    Write-Verbose "[Parse-ACLToken] Token: $Token"
    Write-Verbose "[Parse-ACLToken] Security Namespace: $SecurityNamespace"

    #
    # Git Repositories
    if ($SecurityNamespace -eq 'Git Repositories') {
        # Match the Token with the Regex Patterns
        switch -regex ($Token.Trim()) {
            $LocalizedDataAzACLTokenPatten.OrganizationGit {
                $result.type = 'OrganizationGit'
                break;
            }

            $LocalizedDataAzACLTokenPatten.GitProject {
                $result.type = 'GitProject'
                break;
            }

            $LocalizedDataAzACLTokenPatten.GitRepository {
                $result.type = 'GitRepository'
                break;
            }

            $LocalizedDataAzACLTokenPatten.GitBranch {
                $result.type = 'GitBranch'
                break;
            }

            default {
                throw "Token '$Token' is not recognized."
            }
        }

    #
    # Identity
    } elseif ($SecurityNamespace -eq 'Identity') {

        # Match the Token with the Regex Patterns
        switch -regex ($Token.Trim()) {

            $LocalizedDataAzACLTokenPatten.ResourcePermission {
                $result.type = 'ResourcePermission'
                break;
            }

            $LocalizedDataAzACLTokenPatten.GroupPermission {
                $result.type = 'GroupPermission'
                break;
            }

            default {
                throw "Token '$Token' is not recognized."
            }
        }
    }

    # Get all Capture Groups and add them into a hashtable
    $matches.keys | Where-Object { $_.Length -gt 1 } | ForEach-Object {
        $result."$_" = $matches."$_"
    }

    $result._token = $Token

    return $result
}
