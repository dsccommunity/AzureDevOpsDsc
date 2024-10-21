<#
.SYNOPSIS
    This class represents an Azure DevOps project.

.DESCRIPTION
    The AzDoProject class is used to define and manage Azure DevOps projects. It inherits from the AzDevOpsDscResourceBase class.

.NOTES
    Author: Your Name
    Date:   Current Date

.LINK
    GitHub Repository: <link to the GitHub repository>

.PARAMETER ProjectName
    The name of the Azure DevOps project.

.PARAMETER ProjectDescription
    The description of the Azure DevOps project.

.PARAMETER SourceControlType
    The type of source control for the project. Valid values are 'Git' and 'Tfvc'.

.PARAMETER ProcessTemplate
    The process template for the project. Valid values are 'Agile', 'Scrum', 'CMMI', and 'Basic'.

.PARAMETER Visibility
    The visibility of the project. Valid values are 'Public' and 'Private'.

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    $project = [AzDoProject]::Get()
    $project.ProjectName = 'MyProject'
    $project.ProjectDescription = 'This is a sample project'
    $project.SourceControlType = 'Git'
    $project.ProcessTemplate = 'Agile'
    $project.Visibility = 'Private'
    $project | Set-AzDevOpsProject

#>

[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class AzDoProject : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Name')]
    [System.String]$ProjectName

    [DscProperty()]
    [Alias('Description')]
    [System.String]$ProjectDescription

    [DscProperty()]
    [ValidateSet('Git', 'Tfvc')]
    [System.String]$SourceControlType = 'Git'

    [DscProperty()]
    [ValidateSet('Agile', 'Scrum', 'CMMI', 'Basic')]
    [System.String]$ProcessTemplate = 'Agile'

    [DscProperty()]
    [ValidateSet('Public', 'Private')]
    [System.String]$Visibility = 'Private'

    AzDoProject()
    {
        $this.Construct()
    }

    [AzDoProject] Get()
    {
        return [AzDoProject]$($this.GetDscCurrentStateProperties())
    }


    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        return @('SourceControlType','ProcessTemplate')
    }

    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Ensure = [Ensure]::Absent
        }

        # If the resource object is null, return the properties
        if ($null -eq $CurrentResourceObject)
        {
            return $properties
        }

        $properties.ProjectName         = $CurrentResourceObject.ProjectName
        $properties.ProjectDescription  = $CurrentResourceObject.ProjectDescription
        $properties.SourceControlType   = $CurrentResourceObject.SourceControlType
        $properties.ProcessTemplate     = $CurrentResourceObject.ProcessTemplate
        $properties.Visibility          = $CurrentResourceObject.Visibility
        $properties.LookupResult        = $CurrentResourceObject.LookupResult
        $properties.Ensure              = $CurrentResourceObject.Ensure

        Write-Verbose "[AzDoGroupPermission] Current state properties: $($properties | Out-String)"

        return $properties

    }

}
