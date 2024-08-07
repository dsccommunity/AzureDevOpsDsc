# Usage Documentation

This document provides detailed instructions on how to use the module effectively.

## Prerequisites

Ensure you have the following prerequisites before proceeding:

- **PowerShell 7.0**
- **Required Modules**:
  - `ChangelogManagement`
  - `Configuration`
  - `DscResource.AnalyzerRules`
  - `DscResource.Common`
  - `DscResource.DocGenerator`
  - `DscResource.Test`
  - `InvokeBuild`
  - `MarkdownLinkCheck`
  - `Metadata`
  - `ModuleBuilder`
  - `Pester`
  - `Plaster`
  - `PSDepend`
  - `PSDscResources`
  - `PSScriptAnalyzer`
  - `Sampler`
  - `xDSCResourceDesigner`

### Setting Up: *AZDODSC_CACHE_DIRECTORY* Environment Variable

The system environment variable `AZDODSC_CACHE_DIRECTORY` is used by the module to store caching settings and the cache itself.
Make sure this variable is properly set up in your system environment.

## Setting Up Managed Identity

Please use the following [documentation](https://learn.microsoft.com/en-us/azure/devops/integrate/get-started/authentication/service-principal-managed-identity?view=azure-devops) as a guide to create a managed identity in Azure DevOps.

## Authentication

Prior to accessing any resources, it is necessary to configure authentication by utilizing the `New-AzDoAuthenticationProvider` cmdlet.

```powershell
New-AzDoAuthenticationProvider -OrganizationName $AzureDevopsOrganizationName -UseManagedIdentity
```

## Sample Invocation

Here is an example of how to invoke a resource using the module:

1. Import the necessary modules:

    ```powershell
    Import-Module "\AzureDevOpsDsc\0.0.1\Modules\DscResource.Common\0.17.1\DscResource.Common.psd1"
    Import-Module "\AzureDevOpsDsc\0.0.1\Modules\AzureDevOpsDsc.Common\AzureDevOpsDsc.Common.psd1"
    Import-Module "\AzureDevOpsDsc\0.0.1\AzureDevOpsDsc.psd1"
    ```

1. Create a Managed Identity Token:

    ```powershell
    New-AzDoAuthenticationProvider -OrganizationName "akkodistestorg" -UseManagedIdentity
    ```

1. Define the properties to be used by the module:

    ```powershell
    $properties = @{
      ProjectName = 'UpdateSharePoint'
      GroupName = 'TESTGROUP5'
    }
    ```

1. Invoke the DSC Resource:

    ```powershell
    Invoke-DscResource -Name 'xAzDoProjectGroup' -Method Set -Property $properties -ModuleName 'AzureDevOpsDsc'
    ```

By following these steps, you can successfully set up and use the module with Azure DevOps.
