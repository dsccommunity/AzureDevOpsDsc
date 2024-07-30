function New-AzDevOpsProject
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
    # Construct the parameters for the API call
    $parameters = @{
        organization = $OrganizationName
        projectName  = $ProjectName
        description  = $ProjectDescription
        sourceControlType = $SourceControlType
        processTemplateId = $ProcessTemplate
        visibility = $Visibility
    }

    #
    # Create the project

    $projectJob = New-DevOpsProject @parameters

    #
    # Wait for the project to be created

    Wait-DevOpsProject -ProjectURL $projectJob.url -Organization $OrganizationName

    #
    # Once the project has been created, refresh the project cache.

    AzDoAPI_0_ProjectCache -OrganizationName $OrganizationName

}


