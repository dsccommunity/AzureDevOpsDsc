<#
.SYNOPSIS
    Configures the services for an Azure DevOps project.

.DESCRIPTION
    The Set-AzDoProjectServices function enables or disables various services for a specified Azure DevOps project.
    It retrieves the project details from the live cache and updates the service status based on the provided parameters.

.PARAMETER ProjectName
    The name of the Azure DevOps project. This parameter is mandatory.

.PARAMETER GitRepositories
    Specifies whether Git repositories should be enabled or disabled. Default is 'Enabled'.
    Acceptable values are 'Enabled' and 'Disabled'.

.PARAMETER WorkBoards
    Specifies whether work boards should be enabled or disabled. Default is 'Enabled'.
    Acceptable values are 'Enabled' and 'Disabled'.

.PARAMETER BuildPipelines
    Specifies whether build pipelines should be enabled or disabled. Default is 'Enabled'.
    Acceptable values are 'Enabled' and 'Disabled'.

.PARAMETER TestPlans
    Specifies whether test plans should be enabled or disabled. Default is 'Enabled'.
    Acceptable values are 'Enabled' and 'Disabled'.

.PARAMETER AzureArtifact
    Specifies whether Azure artifacts should be enabled or disabled. Default is 'Enabled'.
    Acceptable values are 'Enabled' and 'Disabled'.

.PARAMETER LookupResult
    A hashtable containing the lookup results for the project services.

.PARAMETER Ensure
    Specifies whether to ensure the services are in the desired state.

.PARAMETER Force
    A switch parameter to force the operation.

.EXAMPLE
    Set-AzDoProjectServices -ProjectName "MyProject" -GitRepositories "Enabled" -WorkBoards "Disabled"

.NOTES
    This function requires the Get-CacheItem and Set-ProjectServiceStatus functions to be defined.
#>
Function Set-AzDoProjectServices
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

    # Retrive the Repositories from the Live Cache.
    $Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    # Construct a hashtable detailing the group
    ForEach ($PropertyChanged in $LookupResult.propertiesChanged)
    {

        $params = @{
            Organization = $Global:DSCAZDO_OrganizationName
            ProjectId    = $Project.id
            ServiceName  = $PropertyChanged.FeatureId
            Body         = $LookupResult.LiveServices.Keys | Where-Object { $LookupResult.LiveServices[$_].featureId -eq $PropertyChanged.FeatureId } | ForEach-Object { $LookupResult.LiveServices[$_] }
        }

        # Set the Project Service Status
        $params.Body.state = ($PropertyChanged.Expected -eq 'Enabled') ? 1 : 0

        Set-ProjectServiceStatus @params

    }

}
