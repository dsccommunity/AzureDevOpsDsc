
# Fixing
. "C:\Temp\AzureDevOpsDSC\source\Modules\AzureDevOpsDsc.Common\Api\Enums\AzDoGitRepositoryPermission.ps1"

# Load the module
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\Modules\AzureDevOpsDsc.Common\AzureDevOpsDsc.Common.psd1' -Verbose
Import-Module 'C:\Temp\AzureDevOpsDSC\output\AzureDevOpsDsc\0.0.0\AzureDevOpsDsc.psd1' -Verbose

# Create a Managed Identity Token
New-AzManagedIdentity -OrganizationName "akkodistestorg" -Verbose

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName

