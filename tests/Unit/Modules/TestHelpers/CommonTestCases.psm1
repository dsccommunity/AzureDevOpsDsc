

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
                     'ObjectId')]
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

        Null = @(
            $null
        )
    }

    $testCaseValues.String.Whitespace = $testCaseValues.String.Empty + @(
        ' ',
        '  '
    )

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
                     'ObjectId')]
        [System.String]
        $ScopeName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Valid','Invalid','Empty','Null','Whitespace','NullOrWhitespace')]
        [System.String]
        $TestCaseName
    )

    $testCaseValues = Get-TestCaseValue -ScopeName $ScopeName -TestCaseName $TestCaseName

    $testCaseValues | ForEach-Object {

        [hashtable]$testCase = @{}
        $testCase[$ScopeName] = $_
        return $testCase
    }

}
