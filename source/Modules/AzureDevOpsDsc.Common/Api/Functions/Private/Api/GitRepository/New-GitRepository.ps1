<#
.SYNOPSIS
Creates a new Git repository in an Azure DevOps project.

.DESCRIPTION
The `New-GitRepository` function creates a new Git repository within a specified Azure DevOps project.
It uses the Azure DevOps REST API to perform the operation.

.PARAMETER ApiUri
The base URI of the Azure DevOps API.

.PARAMETER Project
The project object containing the project details. This should include at least the project name and ID.

.PARAMETER RepositoryName
The name of the new Git repository to be created.

.PARAMETER SourceRepository
(Optional) The source repository to use for the new repository.

.PARAMETER ApiVersion
(Optional) The API version to use for the Azure DevOps REST API. Defaults to the version returned by `Get-AzDevOpsApiVersion -Default`.

.OUTPUTS
System.Management.Automation.PSObject[]
Returns the created repository object if successful.

.EXAMPLE
PS> New-GitRepository -ApiUri "https://dev.azure.com/organization" -Project $project -RepositoryName "NewRepo"

This example creates a new Git repository named "NewRepo" in the specified Azure DevOps project.

.NOTES
This function requires the `Invoke-AzDevOpsApiRestMethod` function to be defined and available in the session.
#>
Function New-GitRepository
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('URI')]
        [System.String]$ApiUri,

        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [Object]$Project,

        [Parameter(Mandatory = $true)]
        [Alias('Repository')]
        [System.String]$RepositoryName,

        [Parameter()]
        [Alias('Source')]
        [System.String]$SourceRepository,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    Write-Verbose "[New-GitRepository] Creating new repository '$($RepositoryName)' in project '$($Project.name)'"

    # Define parameters for creating a new DevOps group
    $params = @{
        ApiUri = '{0}/{1}/_apis/git/repositories?api-version={2}' -f $ApiUri, $Project.name, $ApiVersion
        Method = 'POST'
        ContentType = 'application/json'
        Body = @{
            name = $RepositoryName
            project = @{
                id = $Project.id
            }
        } | ConvertTo-Json
    }

    # Try to invoke the REST method to create the group and return the result
    try
    {
        $repo = Invoke-AzDevOpsApiRestMethod @params
        Write-Verbose "[New-GitRepository] Repository Created: '$($repo.name)'"
        return $repo
    }
    # Catch any exceptions and write an error message
    catch
    {
        Write-Error "[New-GitRepository] Failed to Create Repository: $_"
    }

}
