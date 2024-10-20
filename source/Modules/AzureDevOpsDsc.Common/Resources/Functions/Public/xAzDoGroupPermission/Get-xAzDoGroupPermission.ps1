
Function Get-xAzDoGroupPermission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$GroupName,

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

    Write-Verbose "[Get-xAzDoGroupPermission] Started."

    # Define the Descriptor Type and Organization Name
    $SecurityNamespace = 'Identity'
    $OrganizationName = $Global:DSCAZDO_OrganizationName
    # Split the Group Name
    $split = $GroupName.Split('\').Split('/')

    # Test if the Group Name is valid
    if ($split.Count -ne 2) {
        Write-Warning "[Get-xAzDoGroupPermission] Invalid Group Name: $GroupName"
        return
    }

    # Define the Project and Group Name
    $ProjectName = $split[0].Replace('[', '').Replace(']', '')
    $GroupName = $split[1]

    # If the Project Name contains 'organization'. Update the Project Name


    Write-Verbose "[Get-xAzDoGroupPermission] Security Namespace: $SecurityNamespace"
    Write-Verbose "[Get-xAzDoGroupPermission] Organization Name: $OrganizationName"

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

    Write-Verbose "[Get-xAzDoGroupPermission] Group result hashtable constructed."
    Write-Verbose "[Get-xAzDoGroupPermission] Performing lookup of permissions for the group."

    # Define the ACL List
    $ACLList = [System.Collections.Generic.List[Hashtable]]::new()

    #
    # Perform a Lookup within the Cache for the Group
    $group = Get-CacheItem -Key $('[{0}]\{1}' -f $ProjectName, $GroupName) -Type 'LiveGroups'
    $project = Get-CacheItem -Key $ProjectName -Type 'LiveProjects'

    # Test if the Group was found
    if (-not $group) {
        Throw "[Get-xAzDoGroupPermission] Group not found: $('[{0}]\{1}' -f $ProjectName, $GroupName)"
        return
    }

    #
    # Perform Lookup of the Permissions for the Group

    $namespace = Get-CacheItem -Key $SecurityNamespace -Type 'SecurityNamespaces'
    Write-Verbose "[Get-xAzDoGroupPermission] Retrieved namespace: $($namespace.namespaceId)"

    # Add to the ACL Lookup Params
    $getGroupResult.namespace = $namespace

    $ACLLookupParams = @{
        OrganizationName        = $OrganizationName
        SecurityDescriptorId    = $namespace.namespaceId
    }

    # Get the ACL List and format the ACLS
    Write-Verbose "[Get-xAzDoGroupPermission] ACL Lookup Params: $($ACLLookupParams | Out-String)"

    $DifferenceACLs = Get-DevOpsACL @ACLLookupParams | ConvertTo-FormattedACL -SecurityNamespace $SecurityNamespace -OrganizationName $OrganizationName
    $DifferenceACLs = $DifferenceACLs | Where-Object {
        ($_.Token.Type -eq 'GroupPermission') -and
        ($_.Token.GroupId -eq $group.originId) -and
        ($_.Token.ProjectId -eq $project.id)
    }

    #
    # Iterate through each of the Permissions and append the permission identity if it contains 'Self' or 'This'
    forEach ($Permission in $Permissions) {
        if ($Permission.Identity -in 'self', 'this') {
            $Permission.Identity = '[{0}]\{1}' -f $ProjectName, $GroupName
        }
    }

    Write-Verbose "[Get-xAzDoGroupPermission] ACL List retrieved and formatted."

    #
    # Convert the Permissions into an ACL Token

    $params = @{
        Permissions         = $Permissions
        SecurityNamespace   = $SecurityNamespace
        isInherited         = $isInherited
        OrganizationName    = $OrganizationName
        TokenName           = "{0}\\{1}" -f $project.id, $group.id
    }

    # Convert the Permissions to an ACL Token
    $ReferenceACLs = ConvertTo-ACL @params | Where-Object { $_.token.Type -ne 'GroupUnknown' }

    # if the ACEs are empty, skip
    if ($ReferenceACLs.aces.Count -eq 0) {
        Write-Verbose "[Get-xAzDoGroupPermission] No ACEs found for the group."
        return
    }

    # Compare the Reference ACLs to the Difference ACLs
    $compareResult = Test-ACLListforChanges -ReferenceACLs $ReferenceACLs -DifferenceACLs $DifferenceACLs
    $getGroupResult.propertiesChanged = $compareResult.propertiesChanged
    $getGroupResult.status = [DSCGetSummaryState]::"$($compareResult.status)"
    $getGroupResult.reason = $compareResult.reason

    # Export the ACL List to a file
    $getGroupResult.ReferenceACLs = $ReferenceACLs
    $getGroupResult.DifferenceACLs = $DifferenceACLs

    # Write
    Write-Verbose "[Get-xAzDoGroupPermission] Result Status: $($getGroupResult.status)"
    Write-Verbose "[Get-xAzDoGroupPermission] Returning Group Result."

    # Return the Group Result
    return $getGroupResult

}

