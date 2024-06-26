<#
.SYNOPSIS
Formats an Access Control List (ACL) object.

.DESCRIPTION
The Format-ACL function takes an ACL object and formats it into a structured format. It matches identities, formats permissions, and creates a formatted ACL object.

.PARAMETER ACL
The ACL object from the pipeline.

.PARAMETER SecurityNamespace
The security namespace as a string.

.PARAMETER OrganizationName
The organization name as a string.

.EXAMPLE
$myACL = Get-ACL -Path "C:\Temp"
$formattedACL = $myACL | Format-ACL -SecurityNamespace "MyNamespace" -OrganizationName "MyOrganization"

This example retrieves an ACL object for a specific path and formats it using the Format-ACL function.

.OUTPUTS
[System.Collections.Generic.List[HashTable]]
A list of formatted ACLs.

.NOTES
Author: Michael Zanatta
Date: 06/26/2024
#>

Function Format-ACL {
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
        Write-Verbose "[Format-ACL] Started."
        $ACLList = [System.Collections.Generic.List[HashTable]]::new()
    }

    process {
        # Logging
        Write-Verbose "[Format-ACL] Processing ACL: $($ACL.token)"
        $ACEs = [System.Collections.Generic.List[HashTable]]::new()
        $ACEEntries = $ACL.acesDictionary.psObject.properties.name
        Write-Verbose "[Format-ACL] Found ACE entries: $($ACEEntries.Count)"
        $ACEEntries | ForEach-Object {
            Write-Verbose "[Format-ACL] Processing ACE entry: $_"
            $ACEs.Add([HashTable]@{
                Name  = $_
                Value = $ACL.acesDictionary."$_"
            })
        }
        Write-Verbose "[Format-ACL] Found ACEs: $($ACEs.Count)"

        # Create the Formatted ACL Object
        foreach ($ACE in $ACEs) {
            Write-Verbose "[Format-ACL] Matching identity for ACE: $($ACE.Name)"
            $ACE."Identity" = Find-Identity -Name $ACE.Name -OrganizationName $OrganizationName
            Write-Verbose "[Format-ACL] Formatting ACE: $($ACE.Name) - Allow $($ACE.value.allow) - Deny $($ACE.value.deny)"
            $ACE."Permissions" = Format-ACEs -Allow $ACE.value.allow -Deny $ACE.value.deny -SecurityNamespace $SecurityNamespace
        }

        Write-Verbose "[Format-ACL] Adding formatted ACL: $($ACL.token)"
        $formattedACL = [HashTable]@{
            token     = Resolve-ACLToken -Token $ACL.token
            inherited = $ACL.inheritPermissions
            aces      = $ACEs
        }
        $ACLList.Add($formattedACL)
    }

    end {
        Write-Verbose "[Format-ACL] Completed."
        return $ACLList
    }
}
