<#
.SYNOPSIS
    Represents a permission object.

.DESCRIPTION
    The Permission class represents a permission object that contains an identity, a list of permissions, and a descriptor type.

.PARAMETER Identity
    The identity associated with the permission.

.PARAMETER Permissions
    The list of permissions associated with the identity.

.PARAMETER DescriptorType
    The descriptor type associated with the permission.

.NOTES
    This class is used to format and convert permissions into a Permission object.

.LINK
    https://example.com/permission-class-documentation

.EXAMPLE
    $permission = [Permission]::new()
    $permission.Identity = "User1"
    $permission.Permissions = @{ "Read" = $true; "Write" = $false }
    $permission.DescriptorType = "File"

    $formattedPermissions = $permission.FormatPermissions($permission.Permissions)

    $convertedPermissions = [Permission]::ConvertTo($formattedPermissions, $permission.DescriptorType)
#>

Class Permission {

    [String]$Identity
    [HashTable[]]$Permissions
    hidden [DescriptorType]$DescriptorType

    Permission() {
    }

    # Constructor
    Permission([HashTable]$Permission, [DescriptorType]$DescriptorType, [Object]$Actions) {

        $this.Identity = $Permission.Identity
        $this.DescriptorType = $DescriptorType
        $this.Permissions = $this.FormatPermissions($Permission.permission, $Actions)

    }



    # Function to format the permissions
    [System.Collections.Generic.List[HashTable]]FormatPermissions([HashTable]$Permissions, [Object]$Actions) {

        # Define an Array List
        $formattedPermissions = [System.Collections.Generic.List[HashTable]]::new()

        # Test if the Permissions is an array
        if ($Actions -isnot [System.Array]) {
            throw "[Permission] Unable to convert the Permissions to a Permission object. The Permissions is not an array."
        }

        # Test if the Permissions is empty
        if ($Permissions.Count -eq 0) {
            throw "[Permission] Unable to convert the Permissions to a Permission object. The Permissions array is empty."
        }

        #
        # Iterate through each of the descriptor types and match them against the list.
        ForEach ($PermissionKey in $Permissions.Keys) {

            $Value = $Permissions."$($PermissionKey)"
           # $action = $Actions | Where-Object { $_.displayName -eq $PermissionKey }

            # Add the Permission
            $formattedPermissions.Add(
                @{ $PermissionKey = $Value }
            )

        }
        # Return the formatted permissions
        return $formattedPermissions

    }

    #
    # Function to convert the imported Permissions list into a Permission object list
    static [Permission[]] ConvertTo([HashTable[]]$Permissions, [String]$DescriptorType, [Object]$SecurityNamespace) {

        # Define an Array List
        $convertedPermissions = [System.Collections.Generic.List[Permission]]::new()

        # Test if the Namespace is empty
        if ($null -eq $SecurityNamespace) {
            Write-Warning "[Permission] Unable to convert the Permissions to a Permission object. The Namespace is empty."
            return $convertedPermissions
        }

        # Test if the Actions within the namespace is empty
        if ($SecurityNamespace.actions.count -eq 0) {
            Write-Warning "[Permission] Unable to convert the Permissions to a Permission object. The Permissions array is empty."
            return $convertedPermissions
        }

        #
        # Iterate through each of the descriptor types and match them against the list.
        $actions = $SecurityNamespace.Actions | Select-Object *, @{Name="FormattedName";Expression={$_.Name.Replace("_", "")}}

        $Permissions | Export-Clixml C:\Temp\Permissions.clixml
        $actions | Export-Clixml C:\Temp\Actions.clixml
        foreach ($permission in $Permissions) {
            $convertedPermissions.Add([Permission]::new($permission, $DescriptorType, $actions))
        }

        # Return the converted permissions
        return $convertedPermissions

    }

}

Function Global:ConvertTo-Permission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [HashTable[]]$Permissions,

        [Parameter(Mandatory)]
        [String]$DescriptorType,

        [Parameter(Mandatory)]
        [Object]$SecurityNamespace
    )

    Write-Verbose "[ConvertTo-Permission] Started."

    # Convert the Permissions to a Permission object
    $convertedPermissions = [Permission]::ConvertTo($Permissions, $DescriptorType, $SecurityNamespace)

    # Return the converted permissions
    return $convertedPermissions

}
