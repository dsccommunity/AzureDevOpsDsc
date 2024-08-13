function Get-xAzDoProject
{
    [CmdletBinding()]
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

    Write-Verbose "[Get-xAzDoProject] Started."

    # Set the organization name
    $OrganizationName = $Global:DSCAZDO_OrganizationName
    Write-Verbose "[Get-xAzDoProject] Organization Name: $OrganizationName"

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
    Write-Verbose "[Get-xAzDoProject] Initial result hashtable constructed."

    # Perform a lookup to see if the project exists in Azure DevOps
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'
    # Set the project description to be a string if it is not already.
    Write-Verbose "[Get-xAzDoProject] Project lookup result: $project"

    $processTemplateObj = Get-CacheItem -Key $ProcessTemplate -Type 'LiveProcesses'
    Write-Verbose "[Get-xAzDoProject] Process template lookup result: $processTemplateObj"

    # Test if the project exists. If the project does not exist, return NotFound
    if (($null -eq $project) -and ($null -ne $ProjectName))
    {
        $result.Status = [DSCGetSummaryState]::NotFound
        Write-Verbose "[Get-xAzDoProject] Project not found."
        return $result
    }

    # Test if the process template exists. If the process template does not exist, throw an error.
    if ($null -eq $processTemplateObj)
    {
        throw "[Get-xAzDoProject] Process template '$processTemplateObj' not found."
    }

    Write-Verbose "[Get-xAzDoProject] Testing source control type."

    # Test if the project is using the same source control type. If the source control type is different, return a conflict.
    if ($SourceControlType -ne $project.SourceControlType)
    {
        Write-Warning "[Get-xAzDoProject] Source control type is different. Current: $($project.SourceControlType), Desired: $SourceControlType"
        Write-Warning "[Get-xAzDoProject] Source control type cannot be changed. Please delete the project and recreate it."
    }

    # If the project description is null, set it to an empty string.
    if ($null -eq $project.description)
    {
        $project | Add-Member -MemberType NoteProperty -Name description -Value ''
        Write-Verbose "[Get-xAzDoProject] Project description was null, set to empty string."
    }

    # Test if the project description is the same. If the description is different, return a conflict.
    if ($ProjectDescription.Trim() -ne $project.description.Trim())
    {
        $result.Status = [DSCGetSummaryState]::Changed
        $result.propertiesChanged += 'Description'
        Write-Verbose "[Get-xAzDoProject] Project description has changed."
    }

    <#
    # Test if the project is using the same process template. If the process template is different, return a conflict.
    if ($ProcessTemplate -ne $project.ProcessTemplate)
    {
        $result.Status = [DSCGetSummaryState]::Changed
        $result.propertiesChanged += 'ProcessTemplate'
    }
    #>

    # Test if the project visibility is the same. If the visibility is different, return a conflict.
    if ($Visibility -ne $project.Visibility)
    {
        $result.Status = [DSCGetSummaryState]::Changed
        $result.propertiesChanged += 'Visibility'
        Write-Verbose "[Get-xAzDoProject] Project visibility has changed."
    }

    # Return the group from the cache
    Write-Verbose "[Get-xAzDoProject] Returning final result."
    return $result
}
