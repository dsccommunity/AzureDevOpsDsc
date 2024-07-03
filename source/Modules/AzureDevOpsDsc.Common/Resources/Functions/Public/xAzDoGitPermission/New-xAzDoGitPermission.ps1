Function New-xAzDoGitPermission {
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

    Write-Verbose "[New-xAzDoGitPermission] Started."


    # Iterate Through each of the Permissions and remove them from the Repository
    ForEach ($Property in $LookupResult.propertiesChanged) {

        Write-Verbose "[New-xAzDoGitPermission] Adding Permission: $($Property.Token)"

        # Construct the ACL Token Parameters
        $ACLTokenParams = @{
            OrganizationName    = $Global:DSCAZDO_OrganizationName
            SecurityNamespaceID = $LookupResult.namespace.namespaceId
            TokenNames          = $Property.Token
        }

        # Remove the Permission from the Repository
        Remove-GitRepositoryPermission @ACLTokenParams

    }



    # Iterate Through the Lookup Result and Construct the Permissions List



}
