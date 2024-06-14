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
    Permission([HashTable]$Permission, [DescriptorType]$DescriptorType) {

        $this.Identity = $Permission.Identity
        $this.DescriptorType = $DescriptorType
        $this.Permissions = FormatPermissions($Permission.Permissions)

    }

    # Function to format the permissions
    FormatPermissions([HashTable[]]$Permissions) {

        # Define an Array List
        $formattedPermissions = [System.Collections.Generic.List[HashTable]]::new()

        # Test if the Permissions is an array
        if ($Permissions -isnot [System.Array]) {
            throw "[Permission] Unable to convert the Permissions to a Permission object. The Permissions is not an array."
        }

        # Test if the Permissions is empty
        if ($Permissions.Length -eq 0) {
            throw "[Permission] Unable to convert the Permissions to a Permission object. The Permissions array is empty."
        }

        # Depending on the DescriptorType, the permissions set will be different
        $moduleSettingsPath = Join-Path -Path $ENV:AZDODSC_CACHE_DIRECTORY -ChildPath "ModuleSettings.clixml"
        # Import the ModuleSettings file
        $ModuleSettings = Import-Clixml -LiteralPath $moduleSettingsPath
        # Import the DescriptorTypes Module
        $DescriptorTypes = Import-Module -LiteralPath $ModuleSettings.DescriptorTypes | Where-Object { $_.Name -eq $this.DescriptorType }

        # Iterate through each of the descriptor types and match them against the list.
        ForEach ($Permission in $Permissions) {

            $Key = $Permission.Keys
            $Value = $Permission.Values

            # Check that the Permission key existing within the descriptor types list.
            if ($DescriptorTypes.Names -notcontains $Key) {
                Write-Warning "[Permission] The Permission key: $($Key) does not exist within the DescriptorTypes list. It will be excluded from the Permission object."
                continue
            }
            # Check that the Permission value is a valid value for the descriptor type.
            if ($DescriptorTypes[$Key].Values -notcontains $Value) {
                Write-Warning "[Permission] The Permission value: $($Permissions[$Permission]) is not a valid value for the DescriptorType: $this.DescriptorType. It will be excluded from the Permission object."
                continue
            }

            # Add the Permission
            $formattedPermissions.Add(@{ $Key = $Value})

        }
        # Return the formatted permissions
        return $formattedPermissions

    }

    #
    # Function to convert the imported Permissions list into a Permission object list
    static [Permission[]] ConvertTo([Object]$Permissions, [DescriptorType]$DescriptorType) {

        #
        # Test if the Permission

        # Test if the Permissions is an array
        if ($Permissions -isnot [System.Array]) {
            throw "[Permission] Unable to convert the Permissions to a Permission object. The Permissions is not an array."
        }

        # Test if the Permissions is empty
        if ($Permissions.Length -eq 0) {
            throw "[Permission] Unable to convert the Permissions to a Permission object. The Permissions array is empty."
        }

        # Iterate through each of the array items and convert them to a Permission object
        $convertedPermissions = [System.Collections.Generic.List[Permission]]::new()

        foreach ($permission in $Permissions) {
            $convertedPermissions.Add([Permission]::new($permission, $DescriptorType))
        }

        # Return the converted permissions
        return $convertedPermissions

    }

}
