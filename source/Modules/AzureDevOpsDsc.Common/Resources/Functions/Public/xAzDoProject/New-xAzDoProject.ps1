function New-xAzDoProject
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


