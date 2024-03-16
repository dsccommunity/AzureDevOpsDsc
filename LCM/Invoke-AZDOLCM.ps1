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

# Define the Report Path
$ReportPath = Join-Path -Path $DSCDirectory -ChildPath "Reports"

# TODO: Fix Class Issue
. "C:\Temp\AzureDevOpsDSC\source\Modules\AzureDevOpsDsc.Common\Api\Enums\AzDoGitRepositoryPermission.ps1"

# Load the module
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\Modules\AzureDevOpsDsc.Common\AzureDevOpsDsc.Common.psd1' -Verbose
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1' -Verbose

# Create a Managed Identity Token
New-AzManagedIdentity -OrganizationName "akkodistestorg" -Verbose

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName

# Initalize the Cache for the Other Items
'Project','Team', 'Group', 'SecurityDescriptor' | ForEach-Object { Initialize-CacheObject -CacheType $_ }

# Locate the Resources and load into Memory

# Invoke the Resouces using the specified method

# Export the cache to the Cache Directory
