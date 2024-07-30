
function Get-AzDevOpsProject
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter()]
        [ValidateScript({ Test-AzDevOpsProjectName -ProjectName $_ -IsValid -AllowWildcard })]
        [Alias('Name')]
        [System.String]
        $ProjectName,

        [Parameter()]
        [Alias('Description')]
        [System.String]
        $ProjectDescription,

        [Parameter()]
        [ValidateSet('Git','Tfvc')]
        [System.String]
        $SourceControlType = 'Git',

        [Parameter()]
        [ValidateSet('Agile', 'Scrum', 'CMMI', 'Basic')]
        [System.String]$ProcessTemplate = 'Agile',

        [Parameter()]
        [ValidateSet('Public', 'Private')]
        [System.String]$Visibility = 'Private'

    )

    # Set the organization name
    $OrganizationName = $Global:DSCAZDO_OrganizationName

    #
    # Construct a hashtable detailing the group
    $result = @{
        #Reasons = $()
        Ensure              = [Ensure]::Absent
        ProjectName         = $ProjectName
        ProjectDescription  = $ProjectDescription
        SourceControlType   = $SourceControlType
        ProcessTemplate     = $ProcessTemplate
        Visibility          = $Visibility
        propertiesChanged   = @()
        status              = $null
    }

    #
    # Perform a lookup to see if the group exists in Azure DevOps
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'
    $processTemplate = Get-CacheItem -Key $ProcessTemplate -Type 'LiveProcesses'

    # Test if the project exists. If the project does not exist, return NotFound
    if (($null -eq $project) -and ($null -ne $ProjectName))
    {
        $result.Status = [DSCGetSummaryState]::NotFound
        return $result
    }

    # Test if the process template exists. If the process template does not exist. Throw an error.
    if ($null -eq $processTemplate)
    {
        throw "[Get-AzDevOpsProject] Process template '$ProcessTemplate' not found."
    }

    # Test if the project is using the same source control type. If the source control type is different, return a conflict.
    if ($SourceControlType -ne $project.SourceControlType)
    {
        Write-Warning "[Get-AzDevOpsProject] Source control type is different. Current: $($project.SourceControlType), Desired: $SourceControlType"
        Write-Warning "[Get-AzDevOpsProject] Source control type cannot be changed. Please delete the project and recreate it."
    }

    # Test if the project is using the same process template. If the process template is different, return a conflict.
    if ($Description -ne $project.Description)
    {
        $result.Status = [DSCGetSummaryState]::Changed
        $result.propertiesChanged += 'Description'
    }

    # Test if the project is using the same process template. If the process template is different, return a conflict.
    if ($ProcessTemplate -ne $project.ProcessTemplate)
    {
        $result.Status = [DSCGetSummaryState]::Changed
        $result.propertiesChanged += 'ProcessTemplate'
    }

    # Test if the project visaibility is the same. If the visibility is different, return a conflict.
    if ($Visibility -ne $project.Visibility)
    {
        $result.Status = [DSCGetSummaryState]::Changed
        $result.propertiesChanged += 'Visibility'
    }

    #
    # Return the group from the cache
    return ([PSCustomObject]$result)

}
