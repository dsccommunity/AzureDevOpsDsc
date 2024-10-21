<#
.SYNOPSIS
Defines the types of tokens used for authentication.

.DESCRIPTION
The TokenType enumeration specifies the different types of tokens that can be used for authentication purposes. This includes Managed Identity, Personal Access Token, and Certificate.

.ENUMERATION MEMBERS
ManagedIdentity
    Represents a managed identity token used for authentication.

PersonalAccessToken
    Represents a personal access token used for authentication.

Certificate
    Represents a certificate used for authentication.

.EXAMPLE
# To use the TokenType enumeration:
$tokenType = [TokenType]::ManagedIdentity

.NOTES
This enumeration is part of the AzureDevOpsDsc module.
#>
enum TokenType
{
    ManagedIdentity
    PersonalAccessToken
    Certificate
}
