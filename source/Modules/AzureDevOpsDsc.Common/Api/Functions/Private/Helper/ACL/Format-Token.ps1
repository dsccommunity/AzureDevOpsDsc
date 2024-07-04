<#
.SYNOPSIS
Formats the token based on its type.

.DESCRIPTION
The Format-Token function is used to format a token based on its type. It takes a token as input and returns the formatted token string.

.PARAMETER Token
The token to format. This parameter is mandatory and accepts an array of objects.

.EXAMPLE
$token = @{
    type = 'GitProject'
    projectId = 'myProject'
    repositoryId = 'myRepo'
}
Format-Token -Token $token
# Output: "repoV2/myProject/myRepo"

.NOTES
This function assumes that the token type is either 'GitOrganization', 'GitProject', or 'GitRepository'. If the token type is not one of these, the function will not format the token and will return an empty string.
#>

Function Format-Token {
    [CmdletBinding()]
    param (
        # Define a mandatory parameter named 'Token' of type Object array
        [Parameter(Mandatory)]
        [Object[]]$Token
    )

    # Output verbose message indicating the function has started
    Write-Verbose "[Format-Token] Started."

    # Initialize variable to store formatted token string
    $string = ""

    # Determine the type of the token and format accordingly
    switch ($Token) {
        # If the token type is 'GitOrganization'
        {$_.type -eq 'GitOrganization'} {
            $string = 'repoV2'
            break
        }
        # If the token type is 'GitProject'
        {$_.type -eq 'GitProject'} {
            $string = 'repoV2/{0}' -f $Token.projectId
            break
        }
        # If the token type is 'GitRepository'
        {$_.type -eq 'GitRepository'} {
            $string = 'repoV2/{0}/{1}' -f $Token.projectId, $Token.RepoId
            break
        }
    }

    # Output verbose message with the token value
    Write-Verbose "[Format-Token] Token: $Token"

    # Return the formatted token string
    return $string
}
