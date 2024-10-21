<#
.SYNOPSIS
Creates a new Azure DevOps organization group.

.DESCRIPTION
The New-AzDoOrganizationGroup function creates a new group in an Azure DevOps organization.
It accepts parameters for the group name, description, lookup result, ensure, and force.
The function logs verbose messages during the creation process and updates the cache with the new group information.

.PARAMETER GroupName
Specifies the name of the group to be created. This parameter is mandatory.

.PARAMETER GroupDescription
Specifies the description of the group to be created. This parameter is optional.

.PARAMETER LookupResult
Specifies a hashtable for lookup results. This parameter is optional.

.PARAMETER Ensure
Specifies the desired state of the group. This parameter is optional.

.PARAMETER Force
Forces the creation of the group without confirmation. This parameter is optional.

.EXAMPLE
PS C:\> New-AzDoOrganizationGroup -GroupName "Developers" -GroupDescription "Development Team"

This command creates a new Azure DevOps group named "Developers" with the description "Development Team".

#>
Function New-AzDoOrganizationGroup
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
    }

    # Write verbose log with the parameters used for creating the group
    Write-Verbose "[New-AzDoOrganizationGroup] Creating a new DevOps group with GroupName: '$($params.GroupName)', GroupDescription: '$($params.GroupDescription)' and ApiUri: '$($params.ApiUri)'"

    # Create a new group
    $group = New-DevOpsGroup @params

    # Update the cache with the new group
    Refresh-CacheIdentity -Identity $group -Key $group.principalName -CacheType 'LiveGroups'

    # Add the group to the Group cache and write to verbose log
    Add-CacheItem -Key $group.principalName -Value $group -Type 'Group'
    Write-Verbose "[New-AzDoOrganizationGroup] Added new group to Group cache with key: '$($group.principalName)'"

    # Update the global AzDoGroup object and write to verbose log
    Set-CacheObject -Content $Global:AzDoGroup -CacheType 'Group'
    Write-Verbose "[New-AzDoOrganizationGroup] Updated global AzDoGroup cache object."

}
