<#
param(

    [Parameter(Mandatory)]
    [String]$DSCDirectory,

    [Parameter(Mandatory)]
    [String]$DSCResourcesPath,

    [Parameter()]
    [String[]]$ResourceNames,

    [Parameter()]
    [ValidateSet('Get', 'Set')]
    [String]$ResourceMethods

)
#>


# Define the Report Path
#$ReportPath = Join-Path -Path $DSCDirectory -ChildPath "Reports"

# Load the module
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\Modules\AzureDevOpsDsc.Common\AzureDevOpsDsc.Common.psd1' -Verbose
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1' -Verbose

# Create a Managed Identity Token
New-AzManagedIdentity -OrganizationName "akkodistestorg" -Verbose

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName

# Locate the Resources and load into Memory

# Invoke the Resouces using the specified method

# Export the cache to the Cache Directory
