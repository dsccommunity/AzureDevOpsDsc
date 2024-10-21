<#
.SYNOPSIS
Removes a Git repository from an Azure DevOps project.

.DESCRIPTION
The Remove-GitRepository function removes a specified Git repository from a given Azure DevOps project using the provided API URI and version.

.PARAMETER ApiUri
The base URI of the Azure DevOps API.

.PARAMETER Project
The project from which the repository will be removed. This should be an object containing the project details.

.PARAMETER Repository
The repository to be removed. This should be an object containing the repository details.

.PARAMETER ApiVersion
The version of the Azure DevOps API to use. If not specified, the default version will be used.

.EXAMPLE
Remove-GitRepository -ApiUri "https://dev.azure.com/organization" -Project $project -Repository $repository

.NOTES
This function uses the Invoke-AzDevOpsApiRestMethod cmdlet to perform the REST API call to remove the repository.
#>
Function Remove-GitRepository
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
        [Alias('Repo')]
        [Object]$Repository,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default)
    )

    Write-Verbose "[Remove-GitRepository] Removing repository '$($Repository.Name)' in project '$($Project.name)'"

    # Define parameters for creating a new DevOps group
    $params = @{
        ApiUri = '{0}/{1}/_apis/git/repositories/{2}?api-version={3}' -f $ApiUri, $Project.name, $Repository.id , $ApiVersion
        Method = 'Delete'
    }

    # Try to invoke the REST method to create the group and return the result
    try
    {
        $null = Invoke-AzDevOpsApiRestMethod @params
        return
    }
    # Catch any exceptions and write an error message
    catch
    {
        Write-Error "[Remove-GitRepository] Failed to Create Repository: $_"
    }

}
