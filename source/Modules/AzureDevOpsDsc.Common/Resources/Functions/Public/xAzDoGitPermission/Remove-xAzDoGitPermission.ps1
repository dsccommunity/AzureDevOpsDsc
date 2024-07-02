Function Remove-xAzDoGitPermission {
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

    Write-Verbose "[Remove-xAzDoGitPermission] Started."

    "Triggered-Remove" | Out-File -FilePath "C:\Temp\verbose_log.txt" -Append

    # Iterate Through each of the Permissions and remove them from the Repository
    ForEach ($Property in $LookupResult.propertiesChanged) {

        $obj = ($null -ne $Property.ReferenceObject) ? $Property.ReferenceObject : $Property.DifferenceObject

        Write-Verbose "[Remove-xAzDoGitPermission] Removing Permission: $($Property.TokenNames)"

        # Construct the ACL Token Parameters
        $ACLTokenParams = @{
            OrganizationName    = $Global:DSCAZDO_OrganizationName
            SecurityNamespaceID = $LookupResult.namespace.namespaceId
            TokenNames          = $Property.TokenNames
        }

        Remove-GitRepositoryPermission @ACLTokenParams

    }

}
