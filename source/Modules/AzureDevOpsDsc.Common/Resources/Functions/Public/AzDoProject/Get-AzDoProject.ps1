<#
.SYNOPSIS
    Retrieves information about an Azure DevOps project.

.DESCRIPTION
    The Get-AzDoProject function retrieves details about an Azure DevOps project, including its name, description, source control type, process template, and visibility. It performs lookups to check if the project and process template exist and returns the project's status and any properties that have changed.

.PARAMETER ProjectName
    The name of the Azure DevOps project. This parameter is validated using the Test-AzDevOpsProjectName function.

.PARAMETER ProjectDescription
    The description of the Azure DevOps project. Defaults to an empty string if not specified.

.PARAMETER SourceControlType
    The source control type of the Azure DevOps project. Valid values are 'Git' and 'Tfvc'. Defaults to 'Git'.

.PARAMETER ProcessTemplate
    The process template used by the Azure DevOps project. Valid values are 'Agile', 'Scrum', 'CMMI', and 'Basic'. Defaults to 'Agile'.

.PARAMETER Visibility
    The visibility of the Azure DevOps project. Valid values are 'Public' and 'Private'. Defaults to 'Private'.

.PARAMETER LookupResult
    A hashtable to store the lookup result.

.PARAMETER Ensure
    Specifies the desired state of the project.

.OUTPUTS
    [System.Management.Automation.PSObject[]]
    Returns a hashtable containing the project's details and status.

.EXAMPLE
    Get-AzDoProject -ProjectName "MyProject" -ProjectDescription "Sample project" -SourceControlType "Git" -ProcessTemplate "Agile" -Visibility "Private"

    Retrieves information about the Azure DevOps project named "MyProject" with the specified parameters.

.NOTES
    This function relies on global variables and other functions such as Get-CacheItem and Test-AzDevOpsProjectName to perform lookups and validations.
#>
function Get-AzDoProject
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param (
        [Parameter()]
        [ValidateScript({ Test-AzDevOpsProjectName -ProjectName $_ -IsValid -AllowWildcard })]
        [Alias('Name')]
        [System.String] $ProjectName,

        [Parameter()]
        [Alias('Description')]
        [System.String] $ProjectDescription = '',

        [Parameter()]
        [ValidateSet('Git', 'Tfvc')]
        [System.String] $SourceControlType = 'Git',

        [Parameter()]
        [ValidateSet('Agile', 'Scrum', 'CMMI', 'Basic')]
        [System.String] $ProcessTemplate = 'Agile',

        [Parameter()]
        [ValidateSet('Public', 'Private')]
        [System.String] $Visibility = 'Private',

        [Parameter()]
        [HashTable] $LookupResult,

        [Parameter()]
        [Ensure] $Ensure
    )

    Write-Verbose "[Get-AzDoProject] Started."

    # Set the organization name
    $OrganizationName = $Global:DSCAZDO_OrganizationName
    Write-Verbose "[Get-AzDoProject] Organization Name: $OrganizationName"

    # Construct a hashtable detailing the group
    $result = @{
        Ensure             = [Ensure]::Absent
        ProjectName        = $ProjectName
        ProjectDescription = $ProjectDescription
        SourceControlType  = $SourceControlType
        ProcessTemplate    = $ProcessTemplate
        Visibility         = $Visibility
        propertiesChanged  = @()
        status             = $null
    }
    Write-Verbose "[Get-AzDoProject] Initial result hashtable constructed."

    # Perform a lookup to see if the project exists in Azure DevOps
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'
    # Set the project description to be a string if it is not already.
    Write-Verbose "[Get-AzDoProject] Project lookup result: $project"

    $processTemplateObj = Get-CacheItem -Key $ProcessTemplate -Type 'LiveProcesses'
    Write-Verbose "[Get-AzDoProject] Process template lookup result: $processTemplateObj"

    # Test if the project exists. If the project does not exist, return NotFound
    if (($null -eq $project) -and ($null -ne $ProjectName))
    {
        $result.Status = [DSCGetSummaryState]::NotFound
        Write-Verbose "[Get-AzDoProject] Project not found."
        return $result
    }

    # Test if the process template exists. If the process template does not exist, throw an error.
    if ($null -eq $processTemplateObj)
    {
        throw "[Get-AzDoProject] Process template '$processTemplateObj' not found."
    }

    Write-Verbose "[Get-AzDoProject] Testing source control type."

    # Test if the project is using the same source control type. If the source control type is different, return a conflict.
    if ($SourceControlType -ne $project.SourceControlType)
    {
        Write-Warning "[Get-AzDoProject] Source control type is different. Current: $($project.SourceControlType), Desired: $SourceControlType"
        Write-Warning "[Get-AzDoProject] Source control type cannot be changed. Please delete the project and recreate it."
    }

    # If the project description is null, set it to an empty string.
    if ($null -eq $project.description)
    {
        $project | Add-Member -MemberType NoteProperty -Name description -Value ''
        Write-Verbose "[Get-AzDoProject] Project description was null, set to empty string."
    }

    # Test if the project description is the same. If the description is different, return a conflict.
    if ($ProjectDescription.Trim() -ne $project.description.Trim())
    {
        $result.Status = [DSCGetSummaryState]::Changed
        $result.propertiesChanged += 'Description'
        Write-Verbose "[Get-AzDoProject] Project description has changed."
    }

    # Test if the project visibility is the same. If the visibility is different, return a conflict.
    if ($Visibility -ne $project.Visibility)
    {
        $result.Status = [DSCGetSummaryState]::Changed
        $result.propertiesChanged += 'Visibility'
        Write-Verbose "[Get-AzDoProject] Project visibility has changed."
    }

    # Return the group from the cache
    Write-Verbose "[Get-AzDoProject] Returning final result."

    return [PSCustomObject]$result

}
