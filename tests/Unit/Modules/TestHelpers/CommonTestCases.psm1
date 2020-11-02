
<#
    .SYNOPSIS
        Returns arrays of values to be used within test cases.

    .PARAMETER ScopeName
        Name of the scope for which the test case values are to be returned.

    .PARAMETER TestCaseName
        The name of the test case values within the scope determined by the 'ScopeName'
        parameter.
#>
function Get-TestCaseValue
{
    [OutputType([hashtable[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('String','ApiUri','Pat',`
                     'ProjectName','OrganizationName',`
                     'ObjectId','OperationId','ProjectId')]
        [System.String]
        $ScopeName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Valid','Invalid','Empty','Null','Whitespace','NullOrWhitespace')]
        [System.String]
        $TestCaseName
    )


    $testCaseValues = @{}


    # String
    $testCaseValues.String = @{

        Valid = @(
            '',
            ' ',
            'a',
            '1',
            'a1',
            'a 1'
            ' a 1'
            'a 1 '
            ' a 1 ')

        Empty = @(
            '',
            [string]::Empty
        )

        Whitespace = @( # NOTE: $testCaseValues.String.Empty
            ' ',
            '  '
        )

        Null = @(
            $null
        )
    }

    $testCaseValues.String.NullOrWhitespace = $testCaseValues.String.Null + $testCaseValues.String.Whitespace


    # ApiUri
    $testCaseValues.ApiUri = @{

        Valid = @(
            'http://someuri.api/_apis/',
            'https://someuri.api/_apis/',
            'http://dev.azure.com/organization/_apis/',
            'https://dev.azure.com/organization/_apis/'
        )

        Invalid = @(

            # Incorrect prefixes
            'ftp://someuri.api/_apis/',
            'someuri.api/_apis/',

            # Missing trailing '/' (after http(s))
            'http:/someuri.api/_apis/',
            'https:/someuri.api/_apis/',


            # Missing trailing '/' (at end of URI)
            'http://someuri.api/_apis'
            'https://someuri.api/_apis',


            # Missing trailing '/_apis/' in URI
            'http://someuri.api/'
            'https://someuri.api/'
        )

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }


    # Pat
    $testCaseValues.Pat = @{

        Valid = @(
            '1234567890123456789012345678901234567890123456789012',
            '0987654321098765432109876543210987654321098765432109',
            '0913uhuh3wedwndfwsni2242msfwneu254uhufs009oosfmikm34'
        )

        Invalid = @(
            '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm3',   # Too short
            '0913uhuh3wedwnd4wsni2242msfwn4u254uhufs009oosfmikm34x', # Too long
            '0913uhuh3wedwnd4wsni2242 sfwn4u254uhufs009oosfmikm3',   # Too short and contains space
            '0913uhuh3wedwnd4wsni2242 sfwn4u254uhufs009oosfmikm34x'  # Too long and contains space
        )

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }


    # OrganizationName
    $testCaseValues.OrganizationName = @{

        Valid = @(
            'OrganizationName',
            'Organization-Name',
            'Organization_Name'
        )

        Invalid = @(
            '%',                                     # Just '%' character
            '*',                                     # Just '*' character
            'Organization%Name',                     # Contains '%'
            'Organization*Name',                     # Contains '*'
            'Organization Name',                     # Contains ' ' (whitespace)
            ' OrganizationName',                     # Leading ' ' (whitespace)
            'OrganizationName ',                     # Trailing ' ' (whitespace)
            ' OrganizationName '                     # Leading and trailing ' ' (whitespace)
        ) + $testCaseValues.String.Whitespace        # Any that are just whitespace characters

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }


    # ProjectName
    $testCaseValues.ProjectName = @{

        Valid = @(
            'ProjectName',
            'Project Name',
            'Project-Name',
            'Project_Name'
        )

        Invalid = @(
            '%',                                     # Just '%' character
            '*',                                     # Just '*' character
            'Project%Name',                          # Contains '%'
            'Project*Name'                           # Contains '*'
            ' ProjectName',                          # Leading ' ' (whitespace)
            'ProjectName ',                          # Trailing ' ' (whitespace)
            ' ProjectName '                          # Leading and trailing ' ' (whitespace)
        ) + $testCaseValues.String.Whitespace        # Any that are just whitespace characters

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }


    # ObjectId
    $testCaseValues.ObjectId = @{

        Valid = @(
            'd59709e7-6fdf-40c6-88fa-ac5dc10bbfc3',
            '74cd62c6-54b0-4f5f-986f-b4eea2c4c1d0',
            '4fe84ba8-d9f9-4880-ad5e-e18c99a1b2b4'
        )

        Invalid = @(
            'd59709e7-6fdf-40c6-88fa-ac5dc10bbfc',   # Too short
            '74cd62c6-54b0-4f5f-986f-b4eea2c4c1d0a', # Too long
            '74cd62c6554b014f5fa986fcb4eea2c4c1d0'   # No dashes
        )

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }


    # OperationId (derived from ObjectId)
    $testCaseValues.OperationId = $testCaseValues.ObjectId


    # ProjectId (derived from ObjectId)
    $testCaseValues.ProjectId = $testCaseValues.ObjectId


    return $testCaseValues[$ScopeName][$TestCaseName]

}


<#
    .SYNOPSIS
        Returns arrays of test cases (hashtables) to be used within tests.

    .PARAMETER ScopeName
        Name of the scope for which the test cases are to be returned.

    .PARAMETER TestCaseName
        The name of the test cases within the scope determined by the 'ScopeName'
        parameter.
#>
function Get-TestCase
{
    [OutputType([hashtable[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('String','ApiUri','Pat',`
                     'ProjectName','OrganizationName',`
                     'ObjectId','OperationId','ProjectId')]
        [System.String]
        $ScopeName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Valid','Invalid','Empty','Null','Whitespace','NullOrWhitespace')]
        [System.String]
        $TestCaseName
    )

    $testCaseValues = Get-TestCaseValue -ScopeName $ScopeName -TestCaseName $TestCaseName
    [hashtable[]]$testCases = @()

    $testCaseValues | ForEach-Object {

        [hashtable]$testCase = @{}
        $testCase[$ScopeName] = $_
        $testCases += $testCase
    }

    return $testCases
}


<#
    .SYNOPSIS
        Combines/joins 2, input hashtables into 1 output hashtable.

        All keys and their values across both input hashtables are maintained with the
        exception of keys present in both hashtables. In this instance 'Hashtable2' key
        values are maintained for duplicated keys.

    .PARAMETER Hashtable1
        A hash table to be joined with another provided in the 'Hashtable2' parameter.

        This hashtables keys values are overidden by the values from 'Hashtable2' if
        there are keys present in both 'Hashtable1' and 'Hashtable2'.

    .PARAMETER Hashtable2
        A hash table to be joined with another provided in the 'Hashtable1' parameter

        This hashtables keys values are maintained/kept over the values from 'Hashtable1'
        if there are keys present in both 'Hashtable1' and 'Hashtable2'.
#>
function Join-Hashtable
{
    [CmdletBinding()]
    [OutputType([hashtable[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable]
        $Hashtable1,

        [Parameter(Mandatory = $true)]
        [hashtable]
        $Hashtable2
    )

    $keys = $Hashtable1.getenumerator() | foreach-object {$_.key}
    $keys | foreach-object {
        $key = $_
        if ($Hashtable2.containskey($key))
        {
            $Hashtable1.remove($key)
        }
    }
    $Hashtable2 = $Hashtable1 + $Hashtable2
    return $Hashtable2
}



<#
    .SYNOPSIS
        Combines/joins multiple, hashtable arrays into a single, output hashtable array.

    .PARAMETER HashtableArray
        Contains an array of hashtable arrays to be joined into a single hashtable array.

    .PARAMETER Expand
        When this switch is used, a 'Cartesean Product' of input hashtables (within each
        hashtable array, within the array of hashtable arrays provided in the 'HashtableArray'
        parameter).

        The output from this function will contain every combination of hashtable for every
        other hashtable in each of the provided hashtable arrays.
#>
function Join-HashtableArray
{
    [CmdletBinding()]
    [OutputType([hashtable[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[][]]
        $HashtableArray,

        [Parameter()]
        [switch]
        $Expand
    )

    if (!$Expand)
    {
        throw 'Must use "-Expand" switch in "Join-HashtableArray" function (within "CommonTestCases.psm1")'
    }
    else
    {

        [hashtable[]]$previousOutputHashTableArray = @()

        [int]$currentHashtableArrayNo = 0
        [int]$noOfHashtableArrays = $HashtableArray.Count

        while ($currentHashtableArrayNo -lt $noOfHashtableArrays)
        {
            [hashtable[]]$currentOutputHashTableArray = @()

            if ($currentHashtableArrayNo -gt 0)
            {
                $previousOutputHashTableArray | ForEach-Object {
                    $previousOutputHashTable = $_

                    $HashtableArray[$currentHashtableArrayNo] | ForEach-Object {
                        $currentOutputHashTable = $_

                        $currentOutputHashTableArray += Join-Hashtable -Hashtable1 $previousOutputHashTable -Hashtable2 $currentOutputHashTable
                    }
                }
            }
            else {
                $currentOutputHashTableArray = $HashtableArray[$currentHashtableArrayNo]
            }

            $previousOutputHashTableArray = $currentOutputHashTableArray
            $currentHashtableArrayNo++
        }

        return $previousOutputHashTableArray
    }
}


<#
    .SYNOPSIS
        Combines/joins multiple, TestCase arrays into a single, output TestCase array.

    .PARAMETER TestCaseArray
        Contains an array of TestCase arrays to be joined into a single TestCase array.

    .PARAMETER Expand
        When this switch is used, a 'Cartesean Product' of input hashtables (within each
        hashtable array, within the array of hashtable arrays provided in the 'HashtableArray'
        parameter).

        The output from this function will contain every combination of hashtable for every
        other hashtable in each of the provided hashtable arrays.
#>
function Join-TestCaseArray
{
    [CmdletBinding()]
    [OutputType([hashtable[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [hashtable[][]]
        [Alias('TestCases')]
        $TestCaseArray,

        [Parameter()]
        [switch]
        $Expand
    )


    if (!$Expand)
    {
        throw 'Must use "-Expand" switch in "Join-TestCaseArray" function (within "CommonTestCases.psm1")'
    }
    else
    {
        Join-HashtableArray -HashtableArray $TestCaseArray -Expand:$Expand
    }

}
