
Function Get-xAzDoProjectGroupPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [HashTable[]]$GroupName

        [Parameter(Mandatory)]
        [string]$ProjectName,

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

    Write-Verbose "[Get-xAzDoProjectGroupPermission] Started."

    # Define the Descriptor Type and Organization Name
    $SecurityNamespace = 'Project'
    $OrganizationName = $Global:DSCAZDO_OrganizationName

    Write-Verbose "[Get-xAzDoProjectGroupPermission] Security Namespace: $SecurityNamespace"
    Write-Verbose "[Get-xAzDoProjectGroupPermission] Organization Name: $OrganizationName"

    #
    # Construct a hashtable detailing the group

    $getGroupResult = @{
        Ensure = [Ensure]::Absent
        propertiesChanged = @()
        project = $ProjectName
        groupName = $GroupName
        status = $null
        reason = $null
    }

    Write-Verbose "[Get-xAzDoProjectGroupPermission] Group result hashtable constructed."
    Write-Verbose "[Get-xAzDoProjectGroupPermission] Performing lookup of permissions for the group."

    # Define the ACL List
    $ACLList = [System.Collections.Generic.List[Hashtable]]::new()

    #
    # Perform a Lookup within the Cache for the Group
    $group = Get-CacheItem -Key $('[{0}]\{1}' -f $ProjectName, $GroupName) -Type 'LiveGroups'

    # Test if the Group was found
    if (-not $group) {
        Throw "[Get-xAzDoProjectGroupPermission] Group not found: $group"
        return
    }

    #
    # Perform Lookup of the Permissions for the Group

    $namespace = Get-CacheItem -Key $SecurityNamespace -Type 'SecurityNamespaces'
    Write-Verbose "[Get-xAzDoProjectGroupPermission] Retrieved namespace: $($namespace.namespaceId)"

    # Add to the ACL Lookup Params
    $getGroupResult.namespace = $namespace

    $ACLLookupParams = @{
        OrganizationName        = $OrganizationName
        SecurityDescriptorId    = $namespace.namespaceId
    }

    # Get the ACL List and format the ACLS
    Write-Verbose "[Get-xAzDoProjectGroupPermission] ACL Lookup Params: $($ACLLookupParams | Out-String)"

    $DifferenceACLs = Get-DevOpsACL @ACLLookupParams | ConvertTo-FormattedACL -SecurityNamespace $SecurityNamespace -OrganizationName $OrganizationName

    $DifferenceACLs = $DifferenceACLs | Where-Object {
        ($_.Token.Type -eq $SecurityNamespace) -and ($_.Token.Id -eq $group.ACLIdentity.id)
    }

    Write-Verbose "[Get-xAzDoProjectGroupPermission] ACL List retrieved and formatted."

    #
    # Convert the Permissions into an ACL Token

    $params = @{
        Permissions         = $Permissions
        SecurityNamespace   = $SecurityNamespace
        isInherited         = $isInherited
        OrganizationName    = $OrganizationName
        TokenName           = "[{0}]\{1}" -f $ProjectName, $GroupName
    }

    # Convert the Permissions to an ACL Token
    $ReferenceACLs = ConvertTo-ACL @params | Where-Object { $_.token.Type -ne 'GitUnknown' }


    # Compare the Reference ACLs to the Difference ACLs
    $compareResult = Test-ACLListforChanges -ReferenceACLs $ReferenceACLs -DifferenceACLs $DifferenceACLs
    $getGroupResult.propertiesChanged = $compareResult.propertiesChanged
    $getGroupResult.status = [DSCGetSummaryState]::"$($compareResult.status)"
    $getGroupResult.reason = $compareResult.reason

    # Export the ACL List to a file
    $getGroupResult.ReferenceACLs = $ReferenceACLs
    $getGroupResult.DifferenceACLs = $DifferenceACLs

    # Write
    Write-Verbose "[Get-xAzDoProjectGroupPermission] Result Status: $($getGroupResult.status)"
    Write-Verbose "[Get-xAzDoProjectGroupPermission] Returning Group Result."

    # Return the Group Result
    return $getGroupResult

}

