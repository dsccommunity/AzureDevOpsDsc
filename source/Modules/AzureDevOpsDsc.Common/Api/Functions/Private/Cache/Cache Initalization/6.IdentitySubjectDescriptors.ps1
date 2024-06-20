function AzDoAPI_6_IdentitySubjectDescriptors
{
   [CmdletBinding()]
   param(
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

   #
   # Iterate through each of the groups and query the Identity and add to the cache

   $params = @{
       OrganizationName = $OrganizationName
   }

   # Iterate through each of the groups and query the Identity and add to the cache
   ForEach ($AzDoLiveGroup in $AzDoLiveGroups) {

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

   ForEach ($AzDoLiveUser in $AzDoLiveUsers) {

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
           Value = $AzDoLiveGroup
           Type = 'LiveGroups'
           SuppressWarning = $true
       }

       # Add to the cache
       Add-CacheItem @cacheParams

   }

   # Update the cache
   Export-CacheObject -CacheType 'LiveUsers' -Content $AzDoLiveUsers

}
