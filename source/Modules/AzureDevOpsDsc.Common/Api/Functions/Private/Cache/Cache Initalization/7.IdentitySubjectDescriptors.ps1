<#
.SYNOPSIS
    Initializes and updates the identity subject descriptors cache for Azure DevOps groups, users, and service principals.

.DESCRIPTION
    The AzDoAPI_7_IdentitySubjectDescriptors function retrieves and updates the identity subject descriptors for Azure DevOps groups, users, and service principals.
    It uses the provided organization name or a global variable if no organization name is provided. The function enumerates the live groups, users, and service principals
    from the cache, queries their identities, and updates the cache with the retrieved identity information.

.PARAMETER OrganizationName
    The name of the Azure DevOps organization. If not provided, the function uses the global variable $Global:DSCAZDO_OrganizationName.

.EXAMPLE
    PS> AzDoAPI_7_IdentitySubjectDescriptors -OrganizationName "MyOrganization"
    Initializes and updates the identity subject descriptors cache for the specified Azure DevOps organization.

.EXAMPLE
    PS> AzDoAPI_7_IdentitySubjectDescriptors
    Initializes and updates the identity subject descriptors cache using the global organization name.

.NOTES
    This function is part of the AzureDevOpsDsc module and is used internally to manage the identity subject descriptors cache.
#>
function AzDoAPI_7_IdentitySubjectDescriptors
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$OrganizationName
    )

    #
    # Use a verbose statement to indicate the start of the function.

    Write-Verbose "[AzDoAPI_5_PermissionsCache] Started."

    if (-not $OrganizationName)
    {
        Write-Verbose "[AzDoAPI_5_PermissionsCache] No organization name provided as parameter; using global variable."
        $OrganizationName = $Global:DSCAZDO_OrganizationName
    }

    # Enumerate the live group cache
    $AzDoLiveGroups = Get-CacheObject -CacheType 'LiveGroups'
    # Enumerate the live users cache
    $AzDoLiveUsers = Get-CacheObject -CacheType 'LiveUsers'
    # Enumerate the live service principals cache
    $AzDoLiveServicePrinciples = Get-CacheObject -CacheType 'LiveServicePrinciples'

    #
    # Iterate through each of the groups and query the Identity and add to the cache

    $params = @{
        OrganizationName = $OrganizationName
    }

    # Iterate through each of the groups and query the Identity and add to the cache
    ForEach ($AzDoLiveGroup in $AzDoLiveGroups)
    {
        $identity = Get-DevOpsDescriptorIdentity @params -SubjectDescriptor $AzDoLiveGroup.value.descriptor
        $ACLIdentity = [PSCustomObject]@{
            id = $identity.id
            descriptor = $identity.descriptor
            subjectDescriptor = $identity.subjectDescriptor
            providerDisplayName = $identity.providerDisplayName
            isActive = $identity.isActive
            isContainer = $identity.isContainer
        }

        $AzDoLiveGroup.value | Add-Member -MemberType NoteProperty -Name 'ACLIdentity' -Value $ACLIdentity

        $cacheParams = @{
            Key = $AzDoLiveGroup.Key
            Value = $AzDoLiveGroup
            Type = 'LiveGroups'
            SuppressWarning = $true
        }

        # Add to the cache
        Add-CacheItem @cacheParams

    }

    # Update the cache
    Export-CacheObject -CacheType 'LiveGroups' -Content $AzDoLiveGroups

    #
    # Iterate through each of the users and query the Identity and add to the cache

    ForEach ($AzDoLiveUser in $AzDoLiveUsers)
    {
        $identity = Get-DevOpsDescriptorIdentity @params -SubjectDescriptor $AzDoLiveUser.value.descriptor

        $ACLIdentity = [PSCustomObject]@{
            id = $identity.id
            descriptor = $identity.descriptor
            subjectDescriptor = $identity.subjectDescriptor
            providerDisplayName = $identity.providerDisplayName
            isActive = $identity.isActive
            isContainer = $identity.isContainer
        }

        $AzDoLiveUser.value | Add-Member -MemberType NoteProperty -Name 'ACLIdentity' -Value $ACLIdentity

        $cacheParams = @{
            Key = $AzDoLiveUser.Key
            Value = $AzDoLiveUser
            Type = 'LiveUsers'
            SuppressWarning = $true
        }

        # Add to the cache
        Add-CacheItem @cacheParams

    }

    # Update the cache
    Export-CacheObject -CacheType 'LiveUsers' -Content $AzDoLiveUsers

    #
    # Iterate through each of the service principals and query the Identity and add to the cache

    ForEach ($AzDoLiveServicePrinciple in $AzDoLiveServicePrinciples)
    {
        $identity = Get-DevOpsDescriptorIdentity @params -SubjectDescriptor $AzDoLiveServicePrinciple.value.descriptor

        $ACLIdentity = [PSCustomObject]@{
            id = $identity.id
            descriptor = $identity.descriptor
            subjectDescriptor = $identity.subjectDescriptor
            providerDisplayName = $identity.providerDisplayName
            isActive = $identity.isActive
            isContainer = $identity.isContainer
        }

        $AzDoLiveServicePrinciple.value | Add-Member -MemberType NoteProperty -Name 'ACLIdentity' -Value $ACLIdentity

        $cacheParams = @{
            Key = $AzDoLiveServicePrinciple.Key
            Value = $AzDoLiveServicePrinciple
            Type = 'LiveServicePrinciples'
            SuppressWarning = $true
        }

        # Add to the cache
        Add-CacheItem @cacheParams

    }

    # Update the cache
    Export-CacheObject -CacheType 'LiveServicePrinciples' -Content $AzDoLiveServicePrinciples

}
