function Set-AzDevOpsProject
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

    $OrganizationName = $Global:DSCAZDO_OrganizationName

    #
    # Perform a lookup to see if the group exists in Azure DevOps
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'
    $processTemplate = Get-CacheItem -Key $ProcessTemplate -Type 'LiveProcesses'

    #
    # Construct the parameters for the API call
    $parameters = @{
        organization = $OrganizationName
        projectId  = $project.id
        description  = $ProjectDescription
        processTemplateId = $processTemplate.id
        visibility = $Visibility
    }

    #
    # Update the project

    $projectJob = Update-DevOpsProject @parameters

    #
    # Wait for the project to be updated

    Wait-DevOpsProject -ProjectURL $projectJob.url -Organization $OrganizationName

    #
    # Once the project has been created, refresh the project cache.

    AzDoAPI_0_ProjectCache -OrganizationName $OrganizationName

}
