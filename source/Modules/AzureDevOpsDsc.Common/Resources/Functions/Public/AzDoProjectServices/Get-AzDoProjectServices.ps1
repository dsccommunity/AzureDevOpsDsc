<#
.SYNOPSIS
    Retrieves the status of various Azure DevOps project services.

.DESCRIPTION
    The Get-AzDoProjectServices function retrieves the status of various services (Git Repositories, Work Boards, Build Pipelines, Test Plans, and Azure Artifacts) for a specified Azure DevOps project. It compares the current state of these services with the desired state and returns a summary of the differences.

.PARAMETER ProjectName
    The name of the Azure DevOps project.

.PARAMETER GitRepositories
    The desired state of Git Repositories service. Valid values are 'Enabled' or 'Disabled'. Default is 'Enabled'.

.PARAMETER WorkBoards
    The desired state of Work Boards service. Valid values are 'Enabled' or 'Disabled'. Default is 'Enabled'.

.PARAMETER BuildPipelines
    The desired state of Build Pipelines service. Valid values are 'Enabled' or 'Disabled'. Default is 'Enabled'.

.PARAMETER TestPlans
    The desired state of Test Plans service. Valid values are 'Enabled' or 'Disabled'. Default is 'Enabled'.

.PARAMETER AzureArtifact
    The desired state of Azure Artifacts service. Valid values are 'Enabled' or 'Disabled'. Default is 'Enabled'.

.PARAMETER LookupResult
    A hashtable to store lookup results.

.PARAMETER Ensure
    Specifies whether the project services should be present or absent.

.PARAMETER Force
    Forces the command to run without asking for user confirmation.

.OUTPUTS
    [System.Management.Automation.PSObject[]]
    Returns a hashtable containing the status of the project services and any properties that have changed.

.EXAMPLE
    PS C:\> Get-AzDoProjectServices -ProjectName "MyProject" -GitRepositories "Enabled" -WorkBoards "Enabled" -BuildPipelines "Enabled" -TestPlans "Enabled" -AzureArtifact "Enabled"
    Retrieves the status of the specified project services for the project "MyProject" and compares them with the desired state.

.NOTES
    This function relies on the presence of a live cache and specific global variables and localized data parameters.
#>
Function Get-AzDoProjectServices
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$ProjectName,

        [Parameter()]
        [Alias('Repos')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$GitRepositories = 'Enabled',

        [Parameter()]
        [Alias('Board')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$WorkBoards = 'Enabled',

        [Parameter()]
        [Alias('Pipelines')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$BuildPipelines = 'Enabled',

        [Parameter()]
        [Alias('Tests')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$TestPlans = 'Enabled',

        [Parameter()]
        [Alias('Artifacts')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$AzureArtifact = 'Enabled',

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    #
    # Construct a hashtable detailing the group

    $Result = @{
        #Reasons = $()
        Ensure = [Ensure]::Absent
        propertiesChanged = @()
        status = [DSCGetSummaryState]::Unchanged
    }

    # Attempt to retrive the Project from the Live Cache.
    Write-Verbose "[Get-xAzDevOpsProjectServices] Retriving the Project from the Live Cache."

    # Retrive the Repositories from the Live Cache.
    $Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    # If the Project does not exist in the Live Cache, return the Project object.
    if ($null -eq $Project)
    {
        Write-Warning "[Get-xAzDevOpsProjectServices] The Project '$ProjectName' was not found in the Live Cache."
        $Result.Status = [DSCGetSummaryState]::NotFound
        return $Result
    }

    $params = @{
        Organization = $Global:DSCAZDO_OrganizationName
        ProjectId    = $Project.id
    }

    # Enumerate the Project Services.
    $Result.LiveServices = @{
        Repos       = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Repos
        Boards      = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Boards
        Pipelines   = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Pipelines
        Tests       = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_TestPlans
        Artifacts   = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Artifacts
    }

    # Compare the Project Services with the desired state.
    if ($GitRepositories -ne $Result.LiveServices.Repos.state)
    {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $GitRepositories
            FeatureId = $LocalizedDataAzURLParams.ProjectService_Repos
        }
    }

    if ($WorkBoards -ne $Result.LiveServices.Boards.state)
    {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $WorkBoards
            FeatureId = $LocalizedDataAzURLParams.ProjectService_Boards
        }
    }

    if ($BuildPipelines -ne $Result.LiveServices.Pipelines.state)
    {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $BuildPipelines
            FeatureId = $LocalizedDataAzURLParams.ProjectService_Pipelines
        }
    }

    if ($TestPlans -ne $Result.LiveServices.Tests.state)
    {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $TestPlans
            FeatureId = $LocalizedDataAzURLParams.ProjectService_TestPlans
        }
    }

    if ($AzureArtifact -ne $Result.LiveServices.Artifacts.state)
    {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $AzureArtifact
            FeatureId = $LocalizedDataAzURLParams.ProjectService_Artifacts
        }
    }

    return $Result

}
