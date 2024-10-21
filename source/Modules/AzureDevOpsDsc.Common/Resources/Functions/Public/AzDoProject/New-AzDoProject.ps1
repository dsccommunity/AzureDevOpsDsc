<#
.SYNOPSIS
Creates a new Azure DevOps project.

.DESCRIPTION
The New-AzDoProject function creates a new project in Azure DevOps with the specified parameters.
It supports setting the project name, description, source control type, process template, and visibility.
The function also ensures the project is created by waiting for the project creation job to complete and refreshes the cache once the project is created.

.PARAMETER ProjectName
Specifies the name of the Azure DevOps project. The name is validated using the Test-AzDevOpsProjectName function.

.PARAMETER ProjectDescription
Specifies the description of the Azure DevOps project.

.PARAMETER SourceControlType
Specifies the type of source control for the project. Valid values are 'Git' and 'Tfvc'. The default value is 'Git'.

.PARAMETER ProcessTemplate
Specifies the process template for the project. Valid values are 'Agile', 'Scrum', 'CMMI', and 'Basic'. The default value is 'Agile'.

.PARAMETER Visibility
Specifies the visibility of the project. Valid values are 'Public' and 'Private'. The default value is 'Private'.

.PARAMETER LookupResult
Specifies a hashtable for lookup results.

.PARAMETER Ensure
Specifies the desired state of the project.

.PARAMETER Force
Forces the creation of the project without prompting for confirmation.

.EXAMPLE
PS C:\> New-AzDoProject -ProjectName "MyProject" -ProjectDescription "This is a sample project" -SourceControlType "Git" -ProcessTemplate "Agile" -Visibility "Private"

Creates a new Azure DevOps project named "MyProject" with the specified description, source control type, process template, and visibility.

#>
function New-AzDoProject
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

    # Set the organization name
    $OrganizationName = $Global:DSCAZDO_OrganizationName

    #
    # Perform a lookup to see if the group exists in Azure DevOps
    $processTemplateObj = Get-CacheItem -Key $ProcessTemplate -Type 'LiveProcesses'

    #
    # Construct the parameters for the API call
    $parameters = @{
        organization = $OrganizationName
        projectName  = $ProjectName
        description  = $ProjectDescription
        sourceControlType = $SourceControlType
        processTemplateId = $processTemplateObj.id
        visibility = $Visibility
    }

    #
    # Create the project

    $projectJob = New-DevOpsProject @parameters

    #
    # Wait for the project to be created

    Wait-DevOpsProject -ProjectURL $projectJob.url -OrganizationName $OrganizationName

    #
    # Once the project has been created, refresh the entire cache.

    Refresh-AzDoCache -OrganizationName $OrganizationName

}


