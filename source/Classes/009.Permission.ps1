Class Permission {

    [String]$Identity
    [HashTable[]]$Permissions
    hidden [DescriptorType]$DescriptorType

    Permission() {
    }

    Permission([HashTable]$Permission, [DescriptorType]$DescriptorType) {

        $this.Identity = $Permission.Identity
        $this.DescriptorType = $DescriptorType

        # Depending on the DescriptorType, the permissions set will be different



        $this.Permissions = $Permission

    }


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


    }

}
