<#
.SYNOPSIS
Refreshes the cache identity for a given object.

.DESCRIPTION
The Refresh-CacheIdentity function updates the cache identity for a specified object. It performs a lookup to get the ACL descriptor and adds the ACL identity to the object. The updated object is then added to the cache.

.PARAMETER Identity
The object whose cache identity needs to be refreshed. This parameter is mandatory.

.PARAMETER Key
The key associated with the cache item. This parameter is mandatory.

.PARAMETER CacheType
The type of cache to update. This parameter is mandatory and must be one of the valid cache types returned by Get-AzDoCacheObjects.

.EXAMPLE
$identity = Get-IdentityObject
$key = "someKey"
$cacheType = "someCacheType"
Refresh-CacheIdentity -Identity $identity -Key $key -CacheType $cacheType

.NOTES
This function relies on the global variable $Global:DSCAZDO_OrganizationName and the functions Get-DevOpsDescriptorIdentity, Add-CacheItem, Get-CacheObject, and Set-CacheObject.

#>
Function Refresh-CacheIdentity
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Identity,
        [Parameter(Mandatory = $true)]
        [String]$Key,
        [Parameter(Mandatory = $true)]
        [ValidateScript({$_ -in (Get-AzDoCacheObjects)})]
        [String]$CacheType
    )

    #
    # Perform a lookup to get the ACL Descriptor

    $params = @{
        OrganizationName = $Global:DSCAZDO_OrganizationName
        SubjectDescriptor = $Identity.descriptor
    }

    $descriptorIdentity = Get-DevOpsDescriptorIdentity @params

    # Add the ACLIdentity to the object
    $ACLIdentity = [PSCustomObject]@{
        id = $descriptorIdentity.id
        descriptor = $descriptorIdentity.descriptor
        subjectDescriptor = $descriptorIdentity.subjectDescriptor
        providerDisplayName = $descriptorIdentity.providerDisplayName
        isActive = $descriptorIdentity.isActive
        isContainer = $descriptorIdentity.isContainer
    }

    $Identity | Add-Member -MemberType NoteProperty -Name 'ACLIdentity' -Value $ACLIdentity -Force

    #
    # Add the object to the cache
    $cacheParams = @{
        Key = $Key
        Value = $Identity
        Type = $CacheType
        SuppressWarning = $true
    }

    # Add to the cache
    Add-CacheItem @cacheParams

    # Update the cache object
    $currentCache = Get-CacheObject -CacheType $CacheType
    Set-CacheObject -Content $currentCache -CacheType $CacheType

}
