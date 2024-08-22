Function Refresh-CacheIdentity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Object]$Identity,
        [Parameter(Mandatory)]
        [String]$Key,
        [Parameter(Mandatory)]
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
