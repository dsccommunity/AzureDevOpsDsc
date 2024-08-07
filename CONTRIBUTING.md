# Contributing

## Getting Started

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

---

## Understanding the Module

The `AzureDevOpsDsc` module consists of a few key components:

* The Desired State Configuration (DSC) resources (to be used within DSC configurations).

* The nested, `AzureDevOpsDsc.Common` module, which itself, consists of the following
  sets of functions/commands:

  * `Api` - These functions serve as generic wrappers around the Azure DevOps REST API, designed to minimize code duplication and functionality overlap across all resources. The private functions directory is organized into the following categories:

    * `Api` - Contains common functions that perform API calls to the Azure DevOps API using `Invoke-AZDORestMethod`.
    * `Authentication` - Includes common functions that manage authentication with the Azure DevOps API.
    * `Cache` - Houses common functions that handle caching within Azure DevOps.
      > **Note:* The `Cache Initialization` directory is an ordered directory used to initialize and populate the cache when the module is loaded.
    * `Helper` - Contains common helper functions used by resource functions to perform specific tasks.

    * `Resources` - These invoke the `Api` functions/commands to
        manage specific, Azure DevOps REST API resources (e.g. `Projects`).

    * `Server` - These are specific to Azure DevOps
      **Server** - the self-hosted, typically on-premise, edition of Azure DevOps.

    * `Services` - These are specific to Azure DevOps
      **Services** - the Microsoft, cloud-hosted, 'Software-as-a-Service' (SaaS)
      solution.

The layout/structure of the module and it's resources/components is designed to:

* Rely on the consistency and structure of the Azure DevOps REST API
* Clearly scope and separate, distinct functionality and components
* Allow heavy re-use of generic, Azure DevOps REST API wrapper functionality
* Minimise the complexity of the DSC Resources themselves, in turn, aiming to:
  * Reduce the amount of new functionality and effort required to add new, DSC Resources
  * Increase the reliability and robustness of the DSC Resources

---

## Using the Caching Mechanism

The caching mechanism implemented in this module leverages CLIXML (Command-Line Interface XML) to store cached content. This approach ensures that the cached data is serialized into a structured XML format.

### Cache Initialization

Before the cache can be used, it must first be loaded from disk. The behavior during initialization varies based on the type of cache:

* **Conditional Clearing:** The decision to clear the cache upon initialization depends on its type.
* **'Live' Prefix:** If the cache name begins with the prefix 'Live', it will be cleared when loaded into memory. This is because this cache type represents the current live environment.

This method guarantees that caches containing live data are always current, while other cache types maintain their previously stored content.
After the cache is initialized, the `Live*` cache types are populated using functions located in `source\Modules\AzureDevOpsDsc.Common\Api\Functions\Private\Cache\Cache Initialization`.
These functions run sequentially and create or add items as necessary.

To start the cache process, simply call `New-AzDoAuthenticationProvider`.
For manual initialization:

```powershell
# Initialize the Cache

# Initialize the Cache Objects
Get-AzDoCacheObjects | ForEach-Object {
    Initialize-CacheObject -CacheType $_
}

# Iterate through each of the caching commands and initialize the cache.
Get-Command "AzDoAPI_*" | Where-Object Source -eq 'AzureDevOpsDsc.Common' | ForEach-Object {
    . $_.Name -OrganizationName $AzureDevopsOrganizationName -Verbose
}
```

### Cache Update Requirements

Certain resources will need cache updates when their configuration changes.
Please ensure you update the cache accordingly.
If you are dealing with identity-based caches that utilize permissions, it is crucial to include the `ACLIdentity` property attached to the object.
The `ACLIdentity` property is used by the ACL/ACE helper functions to create ACEs/ACLs for the respective security namespace.

For Example:

``` PowerShell
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
```

**Note:** This applies only to objects that do not have the `ACLIdentity` property.

If you are updating the cache after modifying an *existing* object, you can use `Refresh-CacheIdentity` to update the object:

``` PowerShell
  # Update the cache with the new group
  Refresh-CacheIdentity -Identity $group -Key $group.principalName -CacheType 'LiveGroups'
```

### Adding an Item to the Cache

To add an item to the cache use the command `Add-CacheItem` to add the item into the cache memory.
> Please note that it only exists in memory.

``` PowerShell
Add-CacheItem -Key 'KeyName' -Value $Object -Type 'Type'
```

### Writing a CacheItem to Disk

To save the cache to the disk, you can use the `Export-CacheObject` command.
This function writes the specified cache content to a file on your disk.

Here is an example of how to export the cache to a file:

```PowerShell
# Export the 'LiveUsers' cache to a file
Export-CacheObject -CacheType 'LiveUsers' -Content $AzDoLiveUsers
```

In this example:
- `-CacheType 'LiveUsers'` specifies the type of cache being exported.
- `-Content $AzDoLiveUsers` provides the actual cache data to be written to the disk.

### Getting a Cache Item

To retrieve a cache item, you can use either the `Get-CacheItem` or `Find-CacheItem` functions.

### `Get-CacheItem`

The `Get-CacheItem` function is used to perform lookups based on the key set within the cache.
This is useful when you know the specific key of the item you want to retrieve. For example:

```PowerShell
# Check the cache for the group using its key
$livegroup = Get-CacheItem -Key $Key -Type 'LiveGroups'
```

### `Find-CacheItem`

The `Find-CacheItem` function is used to search for calculated properties against a __cache list__.
This is helpful when you need to perform more complex queries, such as checking if an item with certain criteria exists in the cache. For example:

```PowerShell
# Perform a lookup in the live cache to see if the group has been deleted and recreated
$renamedGroup = $livegroup | Find-CacheItem { $_.originId -eq $livegroup.originId }
```

In summary, use `Get-CacheItem` for direct lookups by key and `Find-CacheItem` for more advanced searches based on calculated properties.

### Adding a new Cache Type

To introduce a new cache type into the project, several steps must be completed.

First, find the `Get-AzDoCacheObjects` function and insert the new cache item type into the array.
The `Get-AzDoCacheObjects` function is utilized by components within the module to validate the cache type.
> Note: If this cache item requires updating each time the module loads, prefix it with `'Live*'`.

``` PowerShell
    return @(
        'Project',
        'Team',
        'Group',
        'SecurityDescriptor',
        'LiveGroups',
        'LiveProjects',
        'LiveUsers',
        'LiveGroupMembers',
        'LiveRepositories',
        'LiveServicePrinciples',
        'LiveACLList',
        'LiveProcesses',
        'SecurityNamespaces',
        'NewCacheItem'
    )
```

### Getting an Entire Cache List

There are two ways to retrieve the cache list.
You can retrieve the cache using `Get-CacheObject -CacheType $Type`, or you can directly access the variable in memory by prefixing `AZDO` with the cache type (e.g., `"AZDO$Type"`).

For example, you can use `Get-CacheObject` to retrieve a list of items from the `LiveGroups` cache:

``` PowerShell
$AzDoLiveGroups = Get-CacheObject -CacheType 'LiveGroups'
```

In this example, you can directly access the variable stored in memory and export its contents to the cache:

```PowerShell
# Export the contents of the $AzDoLiveProjects variable to the LiveProjects cache
Export-CacheObject -CacheType 'LiveProjects' -Content $AzDoLiveProjects
```

This command uses the `Export-CacheObject` cmdlet to save the data from the `$AzDoLiveProjects` variable into the `LiveProjects` cache.
The `-CacheType` parameter specifies the type of cache, while the `-Content` parameter provides the actual data to be cached.

## Creating your First Resource

## Running the Tests

If want to know how to run this module's tests you can look at the [Testing Guidelines](https://dsccommunity.org/guidelines/testing-guidelines/#running-tests)

### Setup of **Remote**, Integration Tests

The Integration tests for this module, run as part of this build, require a
disposable instance of Azure DevOps Services that can be used for creating,
updating and deleting `Projects`, `Teams` and other resources within Azure DevOps.

>**IMPORTANT**: The build pipeline itself can run in a non-disposable Azure
>DevOps organization/collection, but ensure you **DO NOT** setup the following
>variables to point at that non-disposable organization/collection. Doing this
>could result in **loss of code/data/service** because the Integration Tests are
>creating and dropping resources within the organization/collection.

Two variables will need setting up in your Azure DevOps, pipeline:

* **`AzureDevOps.Integration.ApiUri`** - Which needs to contain the URI of your disposable,
AzureDevOps, organization API. For example, `https://dev.azure.com/yourDisposableOrganizationNameHere/_apis/`

* **`AzureDevOps.Integration.Pat`** - Which needs to contain the Personal Access
Token (PAT) to be used to connect to the disposable, Azure DevOps instance.

>**IMPORTANT**: Do not use a live/production/working, Azure DevOps Services/Server
>organization/collection in these variables - **This will likely result in data loss.**

### Setup of **Local**, Integration Tests

If you want to run the Integration Tests locally (i.e. on a workstation used for
development), the following actions need to be performed:

* Access/Use of the Local Configuration Manager (LCM) on the local workstation
  requires Administrator permissions on the workstation. As a result, the session/
  tool executing the Integration tests must be running with Administrator
  privileges. Failure to do this will result in an error when the tests are
  initiated.

* You need to set the following environment variables so the build will determine
  it needs to execute the Integration tests, and it can use the [Personal Access Token
  (PAT)](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page)
  and API URI

  ```Powershell
    $env:CI = $true
    $env:CONFIGURATION = 'Integration' 
    $env:AZUREDEVOPSINTEGRATIONAPIURI = 'YourApiUriHere'  # IMPORTANT: Ensure this is a destructable organization/collection
    $env:AZUREDEVOPSINTEGRATIONPAT = 'YourPatHere'        # This PAT must have access to update resources
  ```

>**Important**: It is not recommended to store any Personal Access Token (PAT)
>in plain text within a text file or script. Ensure no PAT token is added to
source control commits as part of changes made. These PATs would likely be
available within the public, commit history and could/would pose a security risk
to your Azure DevOps instance.
