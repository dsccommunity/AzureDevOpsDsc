#
# Craft a new Azure DevOps Managed Identity
# This sets the $Global:DSCAZDO_OrganizationName variable

New-AzManagedIdentity -OrganizationName "Contoso"

# Set the Group Cache
Set-AzDoAPIGroupCache -OrganizationName $Global:DSCAZDO_OrganizationName
Set-AzDoAPIProjectCache -OrganizationName $Global:DSCAZDO_OrganizationName

