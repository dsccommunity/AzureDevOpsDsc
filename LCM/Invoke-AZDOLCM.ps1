param(
    [Parameter(Mandatory)]
    [String]$ConfigurationDirectory,

    [Parameter()]
    [ValidateSet('Test', 'Set')]
    [String]$ResourceMethods='Set'#

    #[Parameter(Mandatory)]
    #[Uri]$DatumURL
)

$ErrorActionPreference = "Stop"

# Define the Report Path
#$ReportPath = Join-Path -Path $DSCDirectory -ChildPath "Reports"

# Load the module

#$VerbosePreference = "Continue"
#Wait-Debugger
Import-Module 'C:\Temp\AzureDevOpsDSC\LCM\Datum\powershell-yaml'
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\Modules\AzureDevOpsDsc.Common\AzureDevOpsDsc.Common.psd1' -Verbose
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1' -Verbose
Import-Module 'C:\Temp\AzureDevOpsDSC\LCM\DSCConfiguration\DscConfiguration.psm1'
Import-Module 'C:\Temp\AzureDevOpsDSC\LCM\Datum\datum\0.40.1\datum.psd1'

#
# Compile the Datum Configuration

Build -OutputPath $ConfigurationDirectory -Verbose

#
# Create an Object Containing the Organization Name.

$moduleSettingsPath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "ModuleSettings.clixml"

$objectSettings = @{
    OrganizationName = "akkodistestorg"
}

$objectSettings | Export-Clixml -LiteralPath $moduleSettingsPath

# Initalize the Cache
'LiveGroups', 'LiveProjects', 'Project','Team', 'Group', 'SecurityDescriptor' | ForEach-Object {
    Initialize-CacheObject -CacheType $_
}

# Create a Managed Identity Token
New-AzManagedIdentity -OrganizationName $objectSettings.OrganizationName -Verbose

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName -Verbose
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName -Verbose

# Clone-DscConfiguration

#
# Invoke the Resources

Get-ChildItem -LiteralPath $ConfigurationDirectory -File -Filter "*.yml" | ForEach-Object { Invoke-DscConfiguration -FilePath $_.Fullname -Mode $ResourceMethods }

