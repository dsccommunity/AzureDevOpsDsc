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

#$VerbosePreference = "Continue"
#Wait-Debugger
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\Modules\AzureDevOpsDsc.Common\AzureDevOpsDsc.Common.psd1' -Verbose
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1' -Verbose

# Initalize the Cache
'LiveGroups', 'LiveProjects', 'Project','Team', 'Group', 'SecurityDescriptor' | ForEach-Object {
    Initialize-CacheObject -CacheType $_
}

#
# Create an Object Containing the Organization Name.

$moduleSettingsPath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "Settings\ModuleSettings.clixml"

$objectSettings = @{
    OrganizationName = "akkodistestorg"
}

$objectSettings | Export-Clixml -LiteralPath $moduleSettingsPath


# Create a Managed Identity Token
New-AzManagedIdentity -OrganizationName $objectSettings.OrganizationName -Verbose

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName -Verbose

# Locate the Resources and load into Memory

# Invoke the Resouces using the specified method

# Export the cache to the Cache Directory
