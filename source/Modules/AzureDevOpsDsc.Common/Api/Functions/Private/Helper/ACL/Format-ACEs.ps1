<#
.SYNOPSIS
Formats the Access Control Entries (ACEs) based on the specified parameters.

.DESCRIPTION
The Format-ACEs function is used to format the Access Control Entries (ACEs) based on the specified parameters. It performs a lookup of the security namespace and creates a new ACE object with the allow and deny actions.

.PARAMETER Allow
Specifies whether to include ACEs with the "Allow" permission. Default value is 0 (false).

.PARAMETER Deny
Specifies whether to include ACEs with the "Deny" permission. Default value is 0 (false).

.PARAMETER SecurityNamespace
Specifies the security namespace to perform the lookup. This parameter is mandatory.

.EXAMPLE
Format-ACEs -Allow $true -Deny $false -SecurityNamespace "MySecurityNamespace"
Returns the ACE object with the "Allow" actions from the specified security namespace.

.EXAMPLE
Format-ACEs -Allow $false -Deny $true -SecurityNamespace "MySecurityNamespace"
Returns the ACE object with the "Deny" actions from the specified security namespace.

.NOTES
This function requires the Get-CacheItem cmdlet from the AzureDevOpsDsc.Common module to perform the security namespace lookup.
#>

Function Format-ACEs
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [bool]$Allow=0,
        [Parameter()]
        [bool]$Deny=0,
        [Parameter(Mandatory)]
        [string]$SecurityNamespace
    )

    #
    # Logging
    Write-Verbose "[Format-ACEs] Started."

    #
    # Perform a Lookup of the Security Namespace
    $SecurityNamespace = Get-CacheItem -Key $SecurityNamespace -Type 'SecurityNamespaces'

    # Create a new ACE Object
    $ACE = @{
        Allow = $SecurityNamespace.actions | Where-Object { $_.bit -band $Allow }
        Deny = $SecurityNamespace.actions | Where-Object { $_.bit -band $Deny }
        DescriptorType = $DescriptorType
    }

    #
    # Return the ACE
    return $ACE
}
