<#
.SYNOPSIS
Formats an Access Control List (ACL) object.

.DESCRIPTION
The ConvertTo-FormattedACL function takes an ACL object and formats it into a structured format. It matches identities, formats permissions, and creates a formatted ACL object.

.PARAMETER ACL
The ACL object from the pipeline.

.PARAMETER SecurityNamespace
The security namespace as a string.

.PARAMETER OrganizationName
The organization name as a string.

.EXAMPLE
$myACL = Get-ACL -Path "C:\Temp"
$formattedACL = $myACL | ConvertTo-FormattedACL -SecurityNamespace "MyNamespace" -OrganizationName "MyOrganization"

This example retrieves an ACL object for a specific path and formats it using the ConvertTo-FormattedACL function.

.OUTPUTS
[System.Collections.Generic.List[HashTable]]
A list of formatted ACLs.

.NOTES
Author: Michael Zanatta
Date: 06/26/2024
#>

Function ConvertTo-FormattedACL {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Object]$ACL,

        [Parameter(Mandatory = $true)]
        [String]$SecurityNamespace,

        [Parameter(Mandatory = $true)]
        [String]$OrganizationName
    )

    begin {
        Write-Verbose "[ConvertTo-FormattedACL] Started."
        $ACLList = [System.Collections.Generic.List[HashTable]]::new()
    }

    process {
        # Logging
        Write-Verbose "[ConvertTo-FormattedACL] Processing ACL: $($ACL.token)"
        Write-Verbose "[ConvertTo-FormattedACL] ACL: $($ACL | ConvertTo-Json)"

        # If the token is empty, skip it.
        if (-not $ACL.token) {
            Write-Verbose "[ConvertTo-FormattedACL] Current token is empty. Skipping."
            Write-Warning "[ConvertTo-FormattedACL] Current token is empty. Skipping. ACL: $($ACL | ConvertTo-Json)"
            return
        }

        $ACEs = [System.Collections.Generic.List[HashTable]]::new()
        $ACEEntries = $ACL.acesDictionary.psObject.properties.name
        Write-Verbose "[ConvertTo-FormattedACL] Found ACE entries: $($ACEEntries.Count)"

        # If the ACE entries are empty, skip it.
        if ($ACEEntries.Count -eq 0) {
            Write-Verbose "[ConvertTo-FormattedACL] Current ACE entries are empty. Skipping."
            Write-Warning "[ConvertTo-FormattedACL] Current ACE entries are empty. Skipping. ACL: $($ACL | ConvertTo-Json)"
            return
        }

        $ACEEntries | ForEach-Object {
            Write-Verbose "[ConvertTo-FormattedACL] Processing ACE entry: $_"
            $ACEs.Add([HashTable]@{
                Name  = $_
                Value = $ACL.acesDictionary."$_"
            })
        }
        Write-Verbose "[ConvertTo-FormattedACL] Found ACEs: $($ACEs.Count)"

        # If the ACEs are empty, skip it.
        if ($ACEs.Count -eq 0) {
            Write-Verbose "[ConvertTo-FormattedACL] Current ACEs are empty. Skipping."
            Write-Warning "[ConvertTo-FormattedACL] Current ACEs are empty. Skipping. ACL: $($ACL | ConvertTo-Json)"
            return
        }

        # Create the Formatted ACL Object
        foreach ($ACE in $ACEs) {
            Write-Verbose "[ConvertTo-FormattedACL] Matching identity for ACE: $($ACE.Name)"
            $ACE."Identity" = Find-Identity -Name $ACE.Name -OrganizationName $OrganizationName
            Write-Verbose "[ConvertTo-FormattedACL] Formatting ACE: $($ACE.Name) - Allow $($ACE.value.allow) - Deny $($ACE.value.deny)"
            $ACE."Permissions" = Format-ACEs -Allow $ACE.value.allow -Deny $ACE.value.deny -SecurityNamespace $SecurityNamespace
        }

        Write-Verbose "[ConvertTo-FormattedACL] Adding formatted ACL: $($ACL.token)"

        $formattedACL = [HashTable]@{
            token     = Parse-ACLToken -Token $ACL.token -SecurityNamespace $SecurityNamespace
            ACL       = $ACL
            inherited = $ACL.inheritPermissions
            aces      = $ACEs
        }
        $ACLList.Add($formattedACL)
    }

    end {
        Write-Verbose "[ConvertTo-FormattedACL] Completed."
        return $ACLList
    }
}
