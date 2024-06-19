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
    [System.Collections.Generic.List[HashTable]]$Permissions
    hidden [DescriptorType]$DescriptorType

    Permission() {
    }

    # Constructor
    Permission([HashTable]$Permission, [DescriptorType]$DescriptorType, [Object]$Actions) {

        $this.Identity = $Permission.Identity
        $this.DescriptorType = $DescriptorType
        $this.Permissions = $this.FormatPermissions($Permission.permissions, $Actions)

    }


    #
    # Function to format the permissions
    [System.Collections.Generic.List[HashTable]]FormatPermissions([Object]$Permissions, [Object]$Actions) {

        Write-Verbose "[Permission]::FormatPermissions() Started."

        # Define an Array List
        $formattedPermissions = [System.Collections.Generic.List[HashTable]]::new()

        # Test if the Permissions is an array
        if ($Actions.GetType().BaseType.Name -eq 'Array') {
            Write-Warning "[Permission] Unable to convert the Permissions to a Permission object. The Permissions is not an array. The Permissions will be ignored."
            return $formattedPermissions
        }

        # Test if the Permissions is empty
        if ($Permissions.Count -eq 0) {
            Write-Warning "[Permission] Unable to convert the Permissions to a Permission object. The Permissions array is empty. The Permissions will be ignored."
            return $formattedPermissions
        }

        #
        # Iterate through each of the descriptor types and match them against the list.
        ForEach ($PermissionKey in $Permissions.Keys) {

            Write-Verbose "[Permission]::FormatPermissions() Processing permission '$PermissionKey'."

            $enumValue = $null
            # Get the value of the permission
            $value = $Permissions."$($PermissionKey)"

            # Test to make sure the permission key is part of the actions
            if ($Actions.DisplayName -notcontains $PermissionKey) {
                Write-Warning "[Permission] The permission '$PermissionKey' is not part of the actions. The permission will be ignored."
                continue
            }

            # Attempt to typecast the value to an ACLPermission
            if (-not([System.Enum]::TryParse([ACLPermission], $Value, [ref]$enumValue))) {
                Write-Warning "[Permission] Unable to convert the value '$Value' to an ACLPermission. The value will be ignored."
                continue
            }

            # Add the Permission
            $formattedPermissions.Add(
                @{ $PermissionKey = $value }
            )

        }

        # Return the formatted permissions
        return $formattedPermissions

    }

    #
    # Function to convert the imported Permissions list into a Permission object list
    static [System.Collections.Generic.List[Permission]] ConvertTo([HashTable[]]$Permissions, [String]$DescriptorType, [Object]$SecurityNamespace) {

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
        foreach ($permission in $permissions) {

            $hashTable = [HashTable]$permission
            $convertedPermissions.Add(
                [Permission]::new($hashTable, $DescriptorType, $SecurityNamespace.actions)
            )
        }

        # Return the converted permissions
        return $convertedPermissions

    }

    <#
    static [System.Collections.Generic.List[Permission]] ConvertFrom([Object]$ACLList) {

        # Define an Array List
        $convertedPermissions = [System.Collections.Generic.List[Permission]]::new()

        #
        # Test that the ACLList is not empty
        if ($ACLList.Count -eq 0) {
            Write-Warning "[Permission] Unable to convert the ACLList to a Permission object. The ACLList is empty."
            return $convertedPermissions
        }

        #
        # Iterate through each of the tokens

    }
    #>


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
