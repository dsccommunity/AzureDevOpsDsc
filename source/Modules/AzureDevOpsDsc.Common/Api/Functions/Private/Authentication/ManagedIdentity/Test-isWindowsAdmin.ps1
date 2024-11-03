<#
.SYNOPSIS
    Checks if the current user has Administrator privileges.

.DESCRIPTION
    The Test-isWindowsAdmin function verifies if the current user is in the Administrator role.
    If the user does not have Administrator privileges, an error is thrown indicating that
    authentication to Azure Arc requires Administrator privileges.

.EXAMPLE
    Test-isWindowsAdmin

    This command checks if the current user has Administrator privileges. If not, an error is thrown.

.NOTES
    This function is used to ensure that the current user has the necessary permissions to
    authenticate to Azure Arc.
#>

Function Test-isWindowsAdmin
{

    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)

    # Check if the current user is in the Administrator role
    ($principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))

}
