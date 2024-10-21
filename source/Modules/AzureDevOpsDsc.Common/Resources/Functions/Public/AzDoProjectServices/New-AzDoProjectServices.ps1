<#
.SYNOPSIS
Creates a new Azure DevOps project with specified services.

.DESCRIPTION
The New-AzDoProjectServices function creates a new Azure DevOps project and configures various services such as Git repositories, work boards, build pipelines, test plans, and Azure artifacts based on the provided parameters.

.PARAMETER ProjectName
Specifies the name of the Azure DevOps project to be created. This parameter is mandatory.

.PARAMETER GitRepositories
Specifies whether Git repositories should be enabled or disabled for the project. Default is 'Enabled'.

.PARAMETER WorkBoards
Specifies whether work boards should be enabled or disabled for the project. Default is 'Enabled'.

.PARAMETER BuildPipelines
Specifies whether build pipelines should be enabled or disabled for the project. Default is 'Enabled'.

.PARAMETER TestPlans
Specifies whether test plans should be enabled or disabled for the project. Default is 'Enabled'.

.PARAMETER AzureArtifact
Specifies whether Azure artifacts should be enabled or disabled for the project. Default is 'Enabled'.

.PARAMETER LookupResult
A hashtable that can be used to store lookup results.

.PARAMETER Ensure
Specifies whether the project should be present or absent.

.PARAMETER Force
If specified, forces the creation of the project even if it already exists.

.OUTPUTS
System.Management.Automation.PSObject[]

.EXAMPLE
PS C:\> New-AzDoProjectServices -ProjectName "MyProject" -GitRepositories "Enabled" -WorkBoards "Enabled" -BuildPipelines "Enabled" -TestPlans "Enabled" -AzureArtifact "Enabled"

Creates a new Azure DevOps project named "MyProject" with all services enabled.
#>
Function New-AzDoProjectServices
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

    # Won't be triggered.

}
