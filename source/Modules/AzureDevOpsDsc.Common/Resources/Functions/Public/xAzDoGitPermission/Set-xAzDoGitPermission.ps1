Function Set-xAzDoGitPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProjectName,

        [Parameter(Mandatory)]
        [string]$RepositoryName,

        [Parameter(Mandatory)]
        [bool]$isInherited,

        [Parameter()]
        [HashTable[]]$Permissions,

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    Write-Verbose "[Set-xAzDoGitPermission] Started."

    "Triggered-Set" | Out-File -FilePath "C:\Temp\verbose_log.txt" -Append

}
