Function Test-isWindowsAdmin
{

    $currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentIdentity)

    # Check if the current user is in the Administrator role
    (-not($principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)))

}
