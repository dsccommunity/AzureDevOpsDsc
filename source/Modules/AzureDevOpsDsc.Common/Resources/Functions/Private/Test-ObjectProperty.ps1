<#
.SYNOPSIS
Checks if a property exists in an object.

.DESCRIPTION
The Test-ObjectProperty function checks if a specified property exists in an object. It supports checking properties in hashtables, PSCustomObjects, and PSObjects.

.PARAMETER Object
The object to check for the existence of the property.

.PARAMETER PropertyName
The name of the property to check for.

.OUTPUTS
System.Boolean
Returns $true if the property exists in the object, otherwise returns $false.

.EXAMPLE
$object = [PSCustomObject]@{
    Name = "John"
    Age = 30
}

Test-ObjectProperty -Object $object -PropertyName "Name"
# Returns $true

Test-ObjectProperty -Object $object -PropertyName "Email"
# Returns $false
#>

Function Test-ObjectProperty {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory)]
        [System.Object]
        $Object,

        [Parameter(Mandatory)]
        [System.String]
        $PropertyName
    )

    # If the object is a hashtable, check if the key exists
    if ($Object -is [System.Collections.Hashtable]) {
        return $Object.ContainsKey($PropertyName)
    }
    # If the object is a PSCustomObject, check if the property exists
    elseif ($Object -is [PSCustomObject]) {
        return $Object.PSObject.Properties.Name -contains $PropertyName
    }
    # If the object is a PSObject, check if the property exists
    elseif ($Object -is [PSObject]) {
        return $Object.PSObject.Properties.Name -contains $PropertyName
    }

    # Return false
    return $false
}
