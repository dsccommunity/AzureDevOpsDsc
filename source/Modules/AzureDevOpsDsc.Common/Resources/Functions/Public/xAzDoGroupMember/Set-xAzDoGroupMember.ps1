Function Set-xAzDoGroupMember {

    param(

        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Members')]
        [System.String[]]$GroupMembers=@(),

        [Parameter()]
        [Alias('Lookup')]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force

    )

    # If the lookup result is not provided, we need to look it up.
    if ($null -eq $LookupResult.propertiesChanged) {
        Throw "[Set-xAzDoGroupMember] - LookupResult.propertiesChanged is required."
    }

    # Fetch the Group Identity
    $params = @{
        GroupIdentity = $GroupIdentity
        ApiUri = 'https://vssps.dev.azure.com/{0}/' -f $Global:DSCAZDO_OrganizationName
    }

    Write-Verbose "[Set-xAzDoGroupMember] Starting group member addition process for group '$GroupName'."

    # If the lookup result is not provided, we need to look it up.
    switch ($LookupResult.propertiesChanged) {

        # Add members
        { $_.action -eq "Add" } {

            # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
            Write-Verbose "[Set-xAzDoGroupMember][ADD] Adding Identity for Principal Name '$($_.value.principalName)'."
            $identity = $_.value

            # Check for circular reference
            if ($GroupIdentity.originId -eq $identity.originId) {
                Write-Warning "[Set-xAzDoGroupMember][ADD] Circular reference detected for member '$($GroupIdentity.principalName)'."
                continue
            }

            # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
            Write-Verbose "[Set-xAzDoGroupMember][ADD] Adding member '$($identity.displayName)' to group '$($params.GroupIdentity.displayName)'."

            $result = New-DevOpsGroupMember @params -MemberIdentity $identity

            # Add the member to the list
            $members.Add($identity)
            Write-Verbose "[Set-xAzDoGroupMember][ADD] Member '$($identity.displayName)' added to the internal list."

        }

        # Remove
        { $_.action -eq "Remove" } {

            # Use the Find-AzDoIdentity function to search for an Azure DevOps identity that matches the given $MemberIdentity.
            Write-Verbose "[Set-xAzDoGroupMember][REMOVE] Removing Identity for Principal Name '$($_.value.principalName)'."
            $identity = $_.value

            # Check for circular reference
            if ($GroupIdentity.originId -eq $identity.originId) {
                Write-Warning "[Set-xAzDoGroupMember][REMOVE] Circular reference detected for member '$($GroupIdentity.principalName)'."
                continue
            }

            # Call the New-DevOpsGroupMember function with a hashtable of parameters to add the found identity as a new member to a group.
            Write-Verbose "[Set-xAzDoGroupMember][REMOVE] Removing member '$($identity.displayName)' to group '$($params.GroupIdentity.displayName)'."

            $result = Remove-DevOpsGroupMember @params -MemberIdentity $identity

            # Add the member to the list
            $members.Add($identity)
            Write-Verbose "[Set-xAzDoGroupMember][REMOVE] Member '$($identity.displayName)' removed from the internal list."

        }

        # Default
        Default {
            Write-Warning "[Set-xAzDoGroupMember] Invalid action '$($_.action)' provided."
        }

    }


    $LookupResult | Export-Clixml C:\Temp\test.xml

    "TRIGGERED" | Out-File "C:\Temp\Set-xAzDoGroupMember.txt"

    $return

}
