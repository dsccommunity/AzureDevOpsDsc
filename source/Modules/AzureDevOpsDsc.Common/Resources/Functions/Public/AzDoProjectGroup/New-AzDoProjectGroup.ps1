<#
.SYNOPSIS
Creates a new Azure DevOps project group.

.DESCRIPTION
The New-AzDoProjectGroup function creates a new group within a specified Azure DevOps project.
It requires the project name and group name as mandatory parameters. Optionally, a description
for the group and a lookup result can be provided. The function also supports a force switch
parameter to override existing settings.

.PARAMETER GroupName
The name of the new group to be created. This parameter is mandatory.

.PARAMETER GroupDescription
An optional description for the new group.

.PARAMETER ProjectName
The name of the Azure DevOps project where the group will be created. This parameter is mandatory.

.PARAMETER LookupResult
An optional hashtable containing lookup results.

.PARAMETER Ensure
An optional parameter to specify the desired state of the group.

.PARAMETER Force
A switch parameter to force the creation of the group, overriding any existing settings.

.EXAMPLE
PS> New-AzDoProjectGroup -GroupName "Developers" -ProjectName "MyProject"

Creates a new group named "Developers" in the "MyProject" Azure DevOps project.

.EXAMPLE
PS> New-AzDoProjectGroup -GroupName "Testers" -GroupDescription "QA Team" -ProjectName "MyProject" -Force

Creates a new group named "Testers" with the description "QA Team" in the "MyProject" Azure DevOps project,
forcing the creation even if the group already exists.

.NOTES
This function relies on the global variable $Global:DSCAZDO_OrganizationName to construct the API URI.
It also interacts with cache functions like Get-CacheItem, Refresh-CacheIdentity, Add-CacheItem, and Set-CacheObject.
#>
Function New-AzDoProjectGroup
{

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Description')]
        [System.String]$GroupDescription,

        [Parameter(Mandatory = $true)]
        [Alias('Project')]
        [System.String]$ProjectName,

        [Parameter()]
        [Alias('Lookup')]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    # Define parameters for creating a new DevOps group
    $params = @{
        GroupName = $GroupName
        GroupDescription = $GroupDescription
        ApiUri = 'https://vssps.dev.azure.com/{0}' -f $Global:DSCAZDO_OrganizationName
        ProjectScopeDescriptor = (Get-CacheItem -Key $ProjectName -Type 'LiveProjects').ProjectDescriptor
    }

    # If the project scope descriptor is not found, write a warning message to the console and return.
    if ($null -eq $params.ProjectScopeDescriptor)
    {
        Write-Warning "[New-AzDoProjectGroup] Unable to find project scope descriptor for project '$ProjectName'. Aborting group creation."
        return
    }

    # Write verbose log before creating a new group
    Write-Verbose "[New-AzDoProjectGroup] Creating a new DevOps group with the following parameters: $($params | Out-String)"

    # Create a new group
    $group = New-DevOpsGroup @params

    # Write verbose log after group creation
    Write-Verbose "[New-AzDoProjectGroup] New DevOps group created: $($group | Out-String)"

    # Update the cache with the new group
    Refresh-CacheIdentity -Identity $group -Key $group.principalName -CacheType 'LiveGroups'

    Add-CacheItem -Key $group.principalName -Value $group -Type 'Group'
    Write-Verbose "[New-AzDoProjectGroup] Added new group to Group cache with key: $($group.principalName)"

    Set-CacheObject -Content $Global:AzDoGroup -CacheType 'Group'
    Write-Verbose "[New-AzDoProjectGroup] Updated global AzDoGroup cache object."

}
