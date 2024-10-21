<#
.SYNOPSIS
Updates an existing Azure DevOps project with the specified parameters.

.DESCRIPTION
The Set-AzDoProject function updates an existing Azure DevOps project with the provided project name, description, source control type, process template, and visibility. It performs a lookup to see if the project exists in Azure DevOps, constructs the parameters for the API call, updates the project, waits for the update to complete, and refreshes the cache.

.PARAMETER ProjectName
Specifies the name of the Azure DevOps project to update. This parameter is validated using the Test-AzDevOpsProjectName function.

.PARAMETER ProjectDescription
Specifies the description of the Azure DevOps project.

.PARAMETER SourceControlType
Specifies the source control type for the project. Valid values are 'Git' and 'Tfvc'. The default value is 'Git'.

.PARAMETER ProcessTemplate
Specifies the process template for the project. Valid values are 'Agile', 'Scrum', 'CMMI', and 'Basic'. The default value is 'Agile'.

.PARAMETER Visibility
Specifies the visibility of the project. Valid values are 'Public' and 'Private'. The default value is 'Private'.

.PARAMETER LookupResult
Specifies a hashtable to store the lookup result.

.PARAMETER Ensure
Specifies whether to ensure the project exists or not.

.PARAMETER Force
Specifies whether to force the update of the project.

.EXAMPLE
Set-AzDoProject -ProjectName "MyProject" -ProjectDescription "This is a sample project" -SourceControlType "Git" -ProcessTemplate "Agile" -Visibility "Private"

This example updates the Azure DevOps project named "MyProject" with the specified description, source control type, process template, and visibility.

#>
function Set-AzDoProject
{
    [CmdletBinding()]
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
        [System.String]$Visibility = 'Private',

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    $OrganizationName = $Global:DSCAZDO_OrganizationName

    #
    # Perform a lookup to see if the group exists in Azure DevOps
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'
    $processTemplateObj = Get-CacheItem -Key $ProcessTemplate -Type 'LiveProcesses'

    #
    # Construct the parameters for the API call
    $parameters = @{
        organization = $OrganizationName
        projectId  = $project.id
        description  = $ProjectDescription
        processTemplateId = $processTemplateObj.id
        visibility = $Visibility
    }

    #
    # Update the project

    $projectJob = Update-DevOpsProject @parameters

    #
    # Wait for the project to be updated

    Wait-DevOpsProject -ProjectURL $projectJob.url -OrganizationName $OrganizationName

    #
    # Once the project has been created, refresh the entire cache.

    Refresh-AzDoCache -OrganizationName $OrganizationName

}
