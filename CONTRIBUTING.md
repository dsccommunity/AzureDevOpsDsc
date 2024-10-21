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

# Creating your First Resource

## Resource Template

Below is a template for creating a class-based DSC resource in PowerShell.

```PowerShell
[DscResource()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSDSCStandardDSCFunctionsInResource', '', Justification='Test() and Set() method are inherited from base, "AzDevOpsDscResourceBase" class')]
class ClassName : AzDevOpsDscResourceBase
{
    [DscProperty(Key, Mandatory)]
    [Alias('Parameter')]
    [System.String]$ResourceParameter

    ClassName()
    {
        $this.Construct()
    }

    [ClassName] Get()
    {
        return [AzDoProject]$($this.GetDscCurrentStateProperties())
    }

    hidden [System.String[]]GetDscResourcePropertyNamesWithNoSetSupport()
    {
        # Properties that don't support Set, yet support New/Remove
        return @('')
    }

    hidden [Hashtable]GetDscCurrentStateProperties([PSCustomObject]$CurrentResourceObject)
    {
        $properties = @{
            Ensure = [Ensure]::Absent
        }

        # If the resource object is null, return the properties
        if ($null -eq $CurrentResourceObject) { return $properties }

        $properties.ResourceParameter   = $CurrentResourceObject.ResourceParameter
        $properties.LookupResult        = $CurrentResourceObject.LookupResult
        $properties.Ensure              = $CurrentResourceObject.Ensure

        return $properties
    }
}
```

## Create the Class Based Resource

To create a class-based DSC Resource, follow the template provided above.
This will serve as the foundation for defining the resource's properties and methods.

## Write Documentation for Resource

### Overview

When documenting your resource, it is essential to use the Get-Help format to ensure consistency and clarity.
This format helps users understand each property and method of your resource, providing them with the necessary information to utilize it effectively. 

### Naming the Resource

The resource name must start with the prefix xAzDo, such as AzDoProject.

### Guidelines for Documentation

1. **Clear and Concise Information**:
   * Ensure that the description of each property and method is straightforward and easy to understand.
   * Avoid unnecessary jargon or overly technical language that may confuse the user.

1. **Detailed Descriptions**:
   * Provide detailed explanations for each property and method.
   * Explain what each property represents and how each method functions within the resource.

1. **Examples**:
   * Include examples where necessary to illustrate usage.
   * Examples should be relevant and demonstrate common use cases to help users understand how to apply the resource in real-world scenarios.

### Get-Help Format

Below is a template you can follow to document your resource using the Get-Help format:

``` PowerShell
<#
# .SYNOPSIS
Briefly describe what the resource does.

# .DESCRIPTION
Provide a more detailed explanation of the resource, including its purpose and functionality.

# .PARAMETER <ParameterName>
Describe each parameter required by the resource. Include details such as data type, default values, and any constraints.

# .EXAMPLE
Show an example of how to use the resource. Include both the code and an explanation of what the example demonstrates.

# .NOTES
Include any additional information that might be relevant, such as author details, version history, or related resources.

# .LINK
Provide links to any related documentation or external resources.
#>
```

### Example Documentation

Here’s an example of how you might document a sample resource:

```Powershell
<#
# .SYNOPSIS
This resource manages the configuration of a web server.

# .DESCRIPTION
The WebServerResource allows administrators to configure various aspects of a web server, including setting up virtual hosts, managing security settings, and configuring modules.

# .PARAMETER ServerName
Specifies the name of the web server. This is a mandatory parameter.
Type: String
Default value: None

# .PARAMETER Port
Specifies the port on which the web server listens.
Type: Integer
Default value: 80

# .EXAMPLE
PS C:\> Set-WebServerConfiguration -ServerName "MyWebServer" -Port 8080

This command configures the web server named 'MyWebServer' to listen on port 8080.

# .NOTES
Author: Jane Doe
Version: 1.0.0

# .LINK
https://docs.example.com/WebServerResource
#>
```

By following these guidelines and utilizing the Get-Help format, you can create comprehensive and user-friendly documentation for your resource.

## Create `Get`, `Test`, `Set`, `New`, `Remove` Functions

### Lifecycle Management Functions for DSC Resources

These functions are crucial for managing the lifecycle of your Desired State Configuration (DSC) resource. They are located at:

`source\Modules\AzureDevOpsDsc.Common\Resources\Functions\Public\ResourceName`

When creating these functions, make sure to add them to the `FunctionsToExport` section in the file located at:

`source\Modules\AzureDevOpsDsc.Common\AzureDevOpsDsc.Common.psd1`.

#### Function Parameters

The parameters of these functions must be consistent and should reflect the properties of the resource. For instance:

##### Resource Definition
```PowerShell
class ClassName : AzDevOpsDscResourceBase {
    [DscProperty(Key, Mandatory)]
    [Alias('Parameter')]
    [System.String]$ResourceParameter
}
```

##### Get-Function Example
```PowerShell
Function Get-ClassName {
    [CmdletBinding()]
    param (
        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure
    )
}
```

#### Additional Parameters

Include additional parameters such as `Ensure` and `LookupResult` to ensure comprehensive functionality.
Here's an example:

```PowerShell
Function Get-ClassName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$ResourceParameter,

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure
    )
}
```

By following this structure, you ensure that your DSC resource management functions are well-defined and consistent with the resource properties.

#### The `Get` Function

The `Get` function performs the lookup of the resource properties and calculates what has changed.
The changed contents are stored within the `LookupResult.PropertiesChanged` property.

```PowerShell
Function Get-AzDoProjectServices {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [Alias('Name')]
        [System.String]$ProjectName,

        [Parameter()]
        [Alias('Repos')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$GitRepositories = 'Enabled',

        [Parameter()]
        [Alias('Board')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$WorkBoards = 'Enabled',

        [Parameter()]
        [Alias('Pipelines')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$BuildPipelines = 'Enabled',

        [Parameter()]
        [Alias('Tests')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$TestPlans = 'Enabled',

        [Parameter()]
        [Alias('Artifacts')]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]$AzureArtifact = 'Enabled',

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    #
    # Construct a hashtable detailing the group

    $Result = @{
        #Reasons = $()
        Ensure = [Ensure]::Absent
        propertiesChanged = @()
        status = [DSCGetSummaryState]::Unchanged
    }

    #
    # Attempt to retrive the Project from the Live Cache.
    Write-Verbose "[Get-xAzDevOpsProjectServices] Retriving the Project from the Live Cache."

    # Retrive the Repositories from the Live Cache.
    $Project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    # If the Project does not exist in the Live Cache, return the Project object.
    if ($null -eq $Project) {
        Write-Warning "[Get-xAzDevOpsProjectServices] The Project '$ProjectName' was not found in the Live Cache."
        $Result.Status = [DSCGetSummaryState]::NotFound
        return $Result
    }

    $params = @{
        Organization = $Global:DSCAZDO_OrganizationName
        ProjectId    = $Project.id
    }

    # Enumerate the Project Services.
    $Result.LiveServices = @{
        Repos       = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Repos
        Boards      = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Boards
        Pipelines   = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Pipelines
        Tests       = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_TestPlans
        Artifacts   = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Artifacts
    }

    # Compare the Project Services with the desired state.
    if ($GitRepositories -ne $Result.LiveServices.Repos.state) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $GitRepositories
            FeatureId = $LocalizedDataAzURLParams.ProjectService_Repos
        }
    }
    if ($WorkBoards -ne $Result.LiveServices.Boards.state) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $WorkBoards
            FeatureId = $LocalizedDataAzURLParams.ProjectService_Boards
        }
    }
    if ($BuildPipelines -ne $Result.LiveServices.Pipelines.state) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $BuildPipelines
            FeatureId = $LocalizedDataAzURLParams.ProjectService_Pipelines
        }
    }
    if ($TestPlans -ne $Result.LiveServices.Tests.state) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $TestPlans
            FeatureId = $LocalizedDataAzURLParams.ProjectService_TestPlans
        }
    }
    if ($AzureArtifact -ne $Result.LiveServices.Artifacts.state) {
        $Result.Status = [DSCGetSummaryState]::Changed
        $Result.propertiesChanged += @{
            Expected = $AzureArtifact
            FeatureId = $LocalizedDataAzURLParams.ProjectService_Artifacts
        }
    }

    return $Result

}
```

### The `LookupResult` Property

The `LookupResult` property holds the results of the resource lookup and any changes detected.

Example:

```PowerShell
# Enumerate the Project Services.
$Result.LiveServices = @{
    Repos       = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Repos
    Boards      = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Boards
    Pipelines   = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Pipelines
    Tests       = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_TestPlans
    Artifacts   = Get-ProjectServiceStatus @params -ServiceName $LocalizedDataAzURLParams.ProjectService_Artifacts
}

# Compare the Project Services with the desired state.
if ($GitRepositories -ne $Result.LiveServices.Repos.state) {
    $Result.Status = [DSCGetSummaryState]::Changed
    $Result.propertiesChanged += @{
        Expected = $GitRepositories
        FeatureId = $LocalizedDataAzURLParams.ProjectService_Repos
    }
}
```

This example demonstrates how to enumerate project services and compare them against the desired state, updating the `LookupResult` property accordingly.

#### The `Status` Property

The `Status` property provides detailed information about the changes identified by the `get` method.
This property indicates the specific status of the item being evaluated, allowing for a clear understanding of its current state.

#### Possible Status Values

* **Changed**: Indicates that the item has undergone modifications.
* **Unchanged**: Signifies that the item remains in its original state with no alterations.
* **NotFound**: Denotes that the item could not be located within AZDO.
* **Renamed**: Implies that the item has been renamed from its original identifier.
* **Missing**: Suggests that the item is absent or has been deleted within AZDO.

Each status value aids in classifying the result of the `get` method, offering clear insights into the changes affecting the item.
This information is utilized by the `Test` method, along with the `Ensure` enum, to determine the appropriate course of action.

For Example:

``` PowerShell
#
# Construct a hashtable detailing the group
$result = @{
    Ensure              = [Ensure]::Absent
    ProjectName         = $ProjectName
    # Other Key/Value items
    propertiesChanged   = @()
    status              = $null
}

# Test if the project exists. If the project does not exist, return NotFound
if (($null -eq $project) -and ($null -ne $ProjectName))
{
    $result.Status = [DSCGetSummaryState]::NotFound
    return $result
}
```

#### Making API Calls

API calls are not made directly within the Get, Set, Test, New, and Remove functions.
Instead, they are abstracted to the `source\Modules\AzureDevOpsDsc.Common\Api\Functions\Private\Api` directory.
This directory contains functions that handle API calls to the respective endpoints.

Here are some sample code snippets:

``` PowerShell
Write-Verbose "[New-GitRepository] Creating new repository '$($RepositoryName)' in project '$($Project.name)'"

# Define parameters for creating a new DevOps group
$params = @{
    ApiUri = '{0}/{1}/_apis/git/repositories?api-version={2}' -f $ApiUri, $Project.name, $ApiVersion
    Method = 'POST'
    ContentType = 'application/json'
    Body = @{
        name = $RepositoryName
        project = @{
            id = $Project.id
        }
    } | ConvertTo-Json
}

# Try to invoke the REST method to create the group and return the result
try {
    $repo = Invoke-AzDevOpsApiRestMethod @params
    Write-Verbose "[New-GitRepository] Repository Created: '$($repo.name)'"
    return $repo
}
# Catch any exceptions and write an error message
catch {
    Write-Error "[New-GitRepository] Failed to Create Repository: $_"
}
```

When writing API calls, utilize `Invoke-AzDevOpsApiRestMethod` to execute the call.
This function will automatically inject authentication headers, manage pagination, and handle rate-limiting.

# Integrating Enhanced Authentication Mechanisms

With the continuous release of new technologies by Microsoft, this module is engineered to support a variety of advanced authentication mechanisms.
This ensures compatibility with the latest security standards and provides flexibility in choosing the most suitable authentication method for your needs.

Important: The current authentication mechanism depends on the Authorization HTTP header.

This means that all authentication requests must include the appropriate credentials within the Authorization header to ensure secure access.
This method is crucial for maintaining the integrity and confidentiality of the data being transmitted.

## 1. Create an Authentication Class

To create an authentication class, you need to add a new class within the `source\Classes` directory.
Ensure that this class is declared before the `[DSCResourceBase]` class.
Additionally, include a global function named `New-ClassName` in this class, which will be invoked by nested modules.

> **Important:** It's acceptable to adjust the execution order to accommodate the class.

### Implementation Template

Below is a template for creating a sample authentication class called `SampleAuthenticationType`.
This class inherits from the `AuthenticationToken` base class and includes methods for validating tokens, checking expiration, and retrieving the access token.
The global function `New-SampleAuthenticationType` is also provided to instantiate the class.

```PowerShell
# Define the SampleAuthenticationType class
Class SampleAuthenticationType : AuthenticationToken {

    # Property to store the value of the authentication token
    [Property]$Value

    # Constructor to initialize the SampleAuthenticationType instance
    SampleAuthenticationType() {
    }

    # Hidden function to validate the ManagedIdentityTokenObj
    Hidden [Bool]isValid($ManagedIdentityTokenObj) {
    }

    # Function to check if the token has expired
    [Bool]isExpired() {
    }

    # Function to return the access token as a string
    [String] Get() {

        # Test the caller
        $this.TestCaller()

        # Return the access token
        return ($this.ConvertFromSecureString($this.access_token))

    }
}

# Global function to create a new SampleAuthenticationType object
Function global:New-SampleAuthenticationType ([PSCustomObject]$Obj) {
    # Create and return a new SampleAuthenticationType object
    return [SampleAuthenticationType]::New($Obj)
}
```

### Detailed Explanation

#### Class Definition

* **Class Declaration**: The `SampleAuthenticationType` class is defined and inherits from the `AuthenticationToken` base class.
  
* **Properties**:
  * `$Value`: A property to store the value of the authentication token.

* **Constructor**:
  * `SampleAuthenticationType()`: A constructor method to initialize instances of the `SampleAuthenticationType` class.

* **Methods**:
  * `isValid($ManagedIdentityTokenObj)`: A hidden method to validate the provided managed identity token object.
  * `isExpired()`: A method to check if the current token has expired.
  * `Get()`: A method to return the access token as a string. This is used by the Modules 

  > **IMPORTANT**: All tokens must be stored as `[SecureString]` in memory to prevent accidental leakage. Additionally, the `Get()` method can only be invoked by approved functions/methods to further mitigate the risk.

#### Global Function

* **New-SampleAuthenticationType**:
  * A global function that creates and returns a new instance of the `SampleAuthenticationType` class using a provided `PSCustomObject`.

### Usage Example

Here is an example of how to use the `SampleAuthenticationType` class and its associated global function:

```PowerShell
# Create a PSCustomObject with necessary properties
$customObject = [PSCustomObject]@{
    Property1 = "Value1"
    Property2 = "Value2"
}

# Create a new SampleAuthenticationType object
$authToken = New-SampleAuthenticationType -Obj $customObject

# Check if the token is valid
$isValid = $authToken.isValid($managedIdentityTokenObj)

# Check if the token is expired
$isExpired = $authToken.isExpired()

# Get the access token
$accessToken = $authToken.Get()
```

By following this template and detailed explanation, you can create a robust authentication class that integrates seamlessly with your PowerShell DSC resources and nested modules.

## 2. Integrate the Authentication Mechanism into `New-AzDoAuthenticationProvider`

In this step, you need to incorporate the authentication mechanism within the `New-AzDoAuthenticationProvider` function.
Ensure that the necessary authentication protocols are properly implemented to facilitate secure access.

## 3. Integrate Changes into `Add-AuthenticationHTTPHeader`

Next, apply the changes to the `Add-AuthenticationHTTPHeader` function.
This involves updating the function to include the new authentication headers, ensuring that each HTTP request is authenticated correctly.

# Enable Verbose Logging

> **IMPORTANT**: Enabling verbose logging will impact performance.

To enable `Write-Verbose` logging, follow these steps:

1. **Create a System Environment Variable**:
    * Name the variable `AZDO_VERBOSELOGGING_FILEPATH`.
    * Set the value of this variable to the desired file path where you want the verbose logs to be stored.

1. **Steps to Create the Environment Variable**:
    * **Windows**:
        1. Open the Start Menu and search for "Environment Variables".
        1. Select "Edit the system environment variables".
        1. In the System Properties window, click on the "Environment Variables" button.
        1. In the Environment Variables window, under the "System variables" section, click "New".
        1. Enter `AZDO_VERBOSELOGGING_FILEPATH` as the variable name.
        1. Enter the full path of the file where you want the logs to be saved as the variable value (e.g., `C:\Logs\AzDoVerbose.log`).
        1. Click "OK" to save the new variable.
        1. Click "OK" again to close the Environment Variables window, and then "OK" to close the System Properties window.

    * **Linux/macOS**:
        1. Open a terminal window.
        1. Edit your shell profile file (e.g., `~/.bashrc`, `~/.zshrc`) using a text editor.
        1. Add the following line to set the environment variable:
            ```sh
            export AZDO_VERBOSELOGGING_FILEPATH="/path/to/your/logfile.log"
            ```
        1. Save the file and close the text editor.
        1. Source the profile file to apply the changes:
            ```sh
            source ~/.bashrc   # or source ~/.zshrc depending on your shell
            ```

1. **Verify the Environment Variable**:
    * To ensure that the environment variable is set correctly, you can use the following command:
        * **Windows** (Command Prompt):
            ```cmd
            echo %AZDO_VERBOSELOGGING_FILEPATH%
            ```
        * ***Windows** (PowerShell):
            ```powershell
            $env:AZDO_VERBOSELOGGING_FILEPATH
            ```
        * **Linux/macOS**:
            ```sh
            echo $AZDO_VERBOSELOGGING_FILEPATH
            ```

By setting the `AZDO_VERBOSELOGGING_FILEPATH` environment variable, you direct the `Write-Verbose` output to the specified file, enabling detailed logging for troubleshooting and monitoring purposes.

Below is an example of the `Write-Verbose` logfile:

``` Text
[2024-08-13 14:10:45] [Invoke-AzDevOpsApiRestMethod] Invoking the Azure DevOps API REST method 'Get'.
[2024-08-13 14:10:45] [Invoke-AzDevOpsApiRestMethod] API URI: https://vssps.dev.azure.com/sample/_apis/graph/Memberships/vssgp.string?direction=down
[2024-08-13 14:10:45] [Add-AuthenticationHTTPHeader] Adding Managed Identity Token to the HTTP Headers.
[2024-08-13 14:10:45] [Add-AuthenticationHTTPHeader] Adding Header
[2024-08-13 14:10:45] [Invoke-AzDevOpsApiRestMethod] No continuation token found. Breaking loop.
[2024-08-13 14:10:45] No members found for group '[TEAM FOUNDATION]\Enterprise Service Accounts'; skipping.
```

# Tests

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
