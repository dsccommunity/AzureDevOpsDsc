Function Get-OperatingSystemInfo
{
    $OS = @{
        Windows = $(
            if ($PSVersionTable.PSVersion.Major -le 5)
            {
                $true
            }
            else
            {
                $IsWindows
            }
        )
        Linux = $(
            if ($null -eq $IsLinux)
            {
                $false
            }
            else
            {
                $IsLinux
            }
        )
        MacOS = $(
            if ($null -eq $IsMacOS)
            {
                $false
            }
            else
            {
                $IsMacOS
            }
        )
    }

    Write-Output $OS

}
