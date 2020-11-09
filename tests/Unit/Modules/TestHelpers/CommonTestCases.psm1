
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
        [System.String]
        $ScopeName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Valid','Invalid','Empty','Null','Whitespace','NullOrWhitespace')]
        [System.String]
        $TestCaseName,

        [Parameter()]
        [Int32]
        $First = -1
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


    # ApiUriAreaName
    $testCaseValues.ApiUriAreaName = @{

        Valid = @(
            'core'
        )

        Invalid = @(

            'invalidApiUriAreaName'
        )

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }



    # HttpContentType
    $testCaseValues.HttpContentType = @{

        Valid = @(
            'application/json'
        )

        Invalid = @(

            'someInvalidHttpContentType'
        ) + $testCaseValues.String.NullOrWhitespace

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }

    # HttpBody
    $testCaseValues.HttpBody = @{

        Valid = @(
            $(@{
                id='someExampleId'
            } | ConvertTo-Json -Compress),
            $(@{
                name='someExampleName'
            } | ConvertTo-Json -Compress)
        ) + $testCaseValues.String.Empty

        Invalid = @(
        )

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }



    # ApiUriResourceName
    $testCaseValues.ApiUriResourceName = @{

        Valid = @(
            'operations',
            'projects'
        )

        Invalid = @(

            'invalidApiUriResourceName'
        )

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }


    # ApiVersion
    $testCaseValues.ApiVersion = @{

        Valid = @(
            '6.0'
        )

        Invalid = @(

            # API versions (currently) unsupported by this module
            '4.1',
            '5.0',
            '5.1',
            '6.1'

            # Random versions
            '1',
            '1 1',
            '1a',
            'a',
            'a.a'

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


    # HttpHeaders
    $testCaseValues.HttpHeaders = @{

        Valid = $testCaseValues.Pat.Valid | ForEach-Object {
            @{
                Authorization = 'Basic ' +
                    [Convert]::ToBase64String(
                        [Text.Encoding]::ASCII.GetBytes(":$_"))
            }
        }

        Invalid = @(
            @{} # Nothing in it
        )

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }

    # RetryAttempts
    $testCaseValues.RetryAttempts = @{

        Valid = @(
            0,1,2,3,4,5
        )

        Invalid = @(
            6,-1,-10
        ) + $testCaseValues.String.NullOrWhitespace

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }

    # RetryIntervalMs
    $testCaseValues.RetryIntervalMs = @{

        Valid = @(
            250, 251, 10000
        )

        Invalid = @(
            249, 10001, -1, 0
        ) + $testCaseValues.String.NullOrWhitespace

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }

    # HttpMethod
    $testCaseValues.HttpMethod = @{

        Valid = @(
            'Get',
            'Post',
            'Put',
            'Patch',
            'Delete'
        )

        Invalid = @(
           'Unknown', 'Invalid'
        ) + $testCaseValues.String.NullOrWhitespace

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


    # ProjectDescription
    $testCaseValues.ProjectDescription = @{

        Valid = @(
            'ProjectDescription',
            'Project Description',
            'Project-Description',
            'Project_Description',
            ''
        )

        Invalid = @(
            '%',                                     # Just '%' character
            '*',                                     # Just '*' character
            'Project%Description',                   # Contains '%'
            'Project*Description'                    # Contains '*'
            ' ProjectDescription',                   # Leading ' ' (whitespace)
            'ProjectDescription ',                   # Trailing ' ' (whitespace)
            ' ProjectDescription '                   # Leading and trailing ' ' (whitespace)
        )

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


    # ResourceName
    $testCaseValues.ResourceName = @{

        Valid = @(
            'Operation',
            'Project'
        )

        Invalid = @(
            'NonResource',
            'SomeOtherInvalidResource',
            'Some Resource',                 # Contains space
            ' Some Resource',                # Leading space
            'Some Resource '                 # Trailing space
        )

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }


    # ResourceId
    $testCaseValues.ResourceId = @{

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


    # ResourcePublicGetFunctionName
    $testCaseValues.ResourcePublicGetFunctionName = @{

        Valid = $testCaseValues.ResourceName.Valid | ForEach-Object {
            "Get-AzDevOps$_"
        }

    }

    # ResourcePublicTestFunctionName
    $testCaseValues.ResourcePublicTestFunctionName = @{

        Valid = $testCaseValues.ResourceName.Valid | ForEach-Object {
            "Test-AzDevOps$_"
        }

    }

    # ResourcePublicFunctionName
    # Combination of all the 'Get', 'New', 'Set', 'Remove' and 'Test' functions for the 'Resource'
    $testCaseValues.ResourcePublicFunctionName = @{

        Valid = [string[]]$testCaseValues.ResourcePublicGetFunctionName.Valid +
                #$testCaseValues.ResourcePublicNewFunctionName.Valid +     # Not needed/wanted for 'NonDscResource' functions (use 'NonDscResource' for this )
                #$testCaseValues.ResourcePublicSetFunctionName.Valid +     # Not needed/wanted for 'NonDscResource' functions (use 'NonDscResource' for this )
                #$testCaseValues.ResourcePublicRemoveFunctionName.Valid +  # Not needed/wanted for 'NonDscResource' functions (use 'NonDscResource' for this )
                [string[]]$testCaseValues.ResourcePublicTestFunctionName.Valid

    }




    # SourceControlType
    $testCaseValues.SourceControlType = @{

        Valid = @(
            'Git',
            'Tfvc'
        )

        Invalid = @(
            '%',                                     # Just '%' character
            '*',                                     # Just '*' character
            ' Git',                                  # Leading ' ' (whitespace)
            ' Tfvc',                                 # Leading ' ' (whitespace)
            'Git ',                                  # Trailing ' ' (whitespace)
            'Tfvc ',                                 # Trailing ' ' (whitespace)
            ' Git '                                  # Leading and trailing ' ' (whitespace)
            ' Tfvc '                                 # Leading and trailing ' ' (whitespace)
        ) + $testCaseValues.String.Whitespace        # Any that are just whitespace characters

        Empty            = $testCaseValues.String.Empty
        Null             = $testCaseValues.String.Null
        NullOrWhitespace = $testCaseValues.String.NullOrWhitespace

    }




    # NonDscResourceName
    # The 'ResourceName' values that are to be excluded from being used as part of a DSC resource (typically treated differently to 'DscResourceName' values)
    $testCaseValues.NonDscResourceName = @{

        Valid = @(
            'Operation'
        )

        Invalid = $testCaseValues

    }
    $testCaseValues.NonDscResourceName.Invalid = $testCaseValues.ResourceName.Valid | Where-Object {
        $_ -notin $testCaseValues.NonDscResourceName.Valid
    }



    # DscResourceName
    # Use 'ResourceName' values, but remove valid 'NonDscResourceName' from 'Valid' array, and add them to the 'Invalid' array
    $testCaseValues.DscResourceName = @{

        Valid = $testCaseValues.ResourceName.Valid | Where-Object { $_ -notin $testCaseValues.NonDscResourceName.Valid } | ForEach-Object { $_ }

        Invalid = $testCaseValues.NonDscResourceName.Valid | ForEach-Object { $_ }
    }



    # DscResourcePublicGetFunctionName
    $testCaseValues.DscResourcePublicGetFunctionName = @{

        Valid = $testCaseValues.DscResourceName.Valid | ForEach-Object {
            "Get-AzDevOps$_"
        }

    }

    # DscResourcePublicNewFunctionName
    $testCaseValues.DscResourcePublicNewFunctionName = @{

        Valid = $testCaseValues.DscResourceName.Valid | ForEach-Object {
            "New-AzDevOps$_"
        }

    }

    # DscResourcePublicSetFunctionName
    $testCaseValues.DscResourcePublicSetFunctionName = @{

        Valid = $testCaseValues.DscResourceName.Valid | ForEach-Object {
            "Set-AzDevOps$_"
        }

    }

    # DscResourcePublicRemoveFunctionName
    $testCaseValues.DscResourcePublicRemoveFunctionName = @{

        Valid = $testCaseValues.DscResourceName.Valid | ForEach-Object {
            "Remove-AzDevOps$_"
        }

    }

    # DscResourcePublicTestFunctionName
    $testCaseValues.DscResourcePublicTestFunctionName = @{

        Valid = $testCaseValues.DscResourceName.Valid | ForEach-Object {
            "Test-AzDevOps$_"
        }

    }

    # DscResourcePublicFunctionName
    # Combination of all the 'Get', 'New', 'Set', 'Remove' and 'Test' functions for the 'DscResource
    $testCaseValues.DscResourcePublicFunctionName = @{

        Valid = [string[]]$testCaseValues.DscResourcePublicGetFunctionName.Valid +
                [string[]]$testCaseValues.DscResourcePublicNewFunctionName.Valid +
                [string[]]$testCaseValues.DscResourcePublicSetFunctionName.Valid +
                [string[]]$testCaseValues.DscResourcePublicRemoveFunctionName.Valid +
                [string[]]$testCaseValues.DscResourcePublicTestFunctionName.Valid

    }



    # ApiResourcePublicFunctionRequiredParameterName
    # Parameter names that must be present on a public, function for an Azure DevOps, API resource - Note: different to 'ApiResourcePublicFunctionMandatoryParameterName'
    $testCaseValues.ApiResourcePublicFunctionRequiredParameterName = @{

        Valid = @(
            'ApiUri',
            'Pat'
        )
    }

    # DscResourcePublicFunctionRequiredParameterName
    # Parameter names that must be present on a public, function for a DSC resource (same as for an API resource) - Note: different to 'DscResourcePublicFunctionMandatoryParameterName'
    $testCaseValues.DscResourcePublicFunctionRequiredParameterName = $testCaseValues.ApiResourcePublicFunctionRequiredParameterName



    # ApiResourcePublicFunctionMandatoryParameterName
    # Parameter names that must be present AND set as 'Mandatory' on a public, function for an Azure DevOps, API resource
    $testCaseValues.ApiResourcePublicFunctionMandatoryParameterName = $testCaseValues.ApiResourcePublicFunctionRequiredParameterName

    # DscResourcePublicFunctionMandatoryParameterName
    # Parameter names that must be present AND set as 'Mandatory' on a public, function for a DSC resource (same as for an API resource)
    $testCaseValues.DscResourcePublicFunctionMandatoryParameterName = $testCaseValues.ApiResourcePublicFunctionMandatoryParameterName




    # ParameterAliasName
    # Parameter names that must be present on a public, function for an Azure DevOps, API resource
    $testCaseValues.ParameterAliasName = @{

        Valid = @(
            @{
                ParameterName='ApiUri'
                AliasName=@('Uri')
            },
            @{
                ParameterName='Pat'
                AliasName=@('PersonalAccessToken')
            }
        )
    }



    # OperationId (derived from ResourceId)
    $testCaseValues.OperationId = $testCaseValues.ResourceId


    # ProjectId (derived from ResourceId)
    $testCaseValues.ProjectId = $testCaseValues.ResourceId


    if ($null -ne $First -and $First -gt -1)
    {
        return $testCaseValues[$ScopeName][$TestCaseName] |
            Select-Object -First $First
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
        [System.String]
        $ScopeName,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Valid','Invalid','Empty','Null','Whitespace','NullOrWhitespace')]
        [System.String]
        $TestCaseName,

        [Parameter()]
        [Int32]
        $First = -1
    )

    $testCaseValues = Get-TestCaseValue -ScopeName $ScopeName -TestCaseName $TestCaseName -First $First
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
        Returns arrays of test cases (hashtables) to be used within tests.

    .PARAMETER ScopeName
        Name of the scope for which the test cases are to be returned.

    .PARAMETER TestCaseName
        The name of the test cases within the scope determined by the 'ScopeName'
        parameter.
#>
function Get-ParameterSetTestCase
{
    [OutputType([hashtable[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        [Alias('FunctionName','MethodName')]
        $CommandName,

        [Parameter()]
        [System.String]
        $ParameterSetName = "__AllParameterSets",

        [Parameter(Mandatory = $true)]
        [ValidateSet('Valid','Invalid')]
        [System.String]
        $TestCaseName,

        [Parameter()]
        [Int32]
        $First = -1
    )

    $ParameterSetTestCases = @{}


    # Invoke-AzDevOpsApiRestMethod
    $validApiUri = Get-TestCaseValue -ScopeName 'ApiUri' -TestCaseName 'Valid' -First 1
    $validHttpMethod = Get-TestCaseValue -ScopeName 'HttpMethod' -TestCaseName 'Valid' -First 1
    $validHttpHeaders = Get-TestCaseValue -ScopeName 'HttpHeaders' -TestCaseName 'Valid' -First 1
    $validHttpBody = Get-TestCaseValue -ScopeName 'HttpBody' -TestCaseName 'Valid' -First 1
    $validHttpContentType = Get-TestCaseValue -ScopeName 'HttpContentType' -TestCaseName 'Valid' -First 1
    $validRetryAttempts = Get-TestCaseValue -ScopeName 'RetryAttempts' -TestCaseName 'Valid' -First 1
    $validRetryIntervalMs = Get-TestCaseValue -ScopeName 'RetryIntervalMs' -TestCaseName 'Valid' -First 1

    $ParameterSetTestCases."Invoke-AzDevOpsApiRestMethod" = @{

        "__AllParameterSets" = @{

            Valid = @(
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    #HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    #HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    #HttpBody = $validHttpBody
                    #HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    #RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    #HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    #RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    #HttpContentType = $validHttpContentType
                    #RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    #HttpBody = $validHttpBody
                    #HttpContentType = $validHttpContentType
                    #RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    #RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    #HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    #RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    #HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    #RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    #RetryAttempts = $validRetryAttempts
                    #RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    #HttpBody = $validHttpBody
                    #HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    #RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    #HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    #RetryAttempts = $validRetryAttempts
                    #RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    #HttpContentType = $validHttpContentType
                    #RetryAttempts = $validRetryAttempts
                    #RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    #HttpBody = $validHttpBody
                    #HttpContentType = $validHttpContentType
                    #RetryAttempts = $validRetryAttempts
                    #RetryIntervalMs = $validRetryIntervalMs
                }
            )

            Invalid = @(
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $null # Mandatory (Set as $null to avoid Pester prompting for value)
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },
                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $null # Mandatory (Set as $null to avoid Pester prompting for value)
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },

                @{
                    ApiUri = Get-TestCaseValue -ScopeName 'ApiUri' -TestCaseName 'Invalid' -First 1
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },

                @{
                    ApiUri = $validApiUri
                    HttpMethod = Get-TestCaseValue -ScopeName 'HttpMethod' -TestCaseName 'Invalid' -First 1
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },

                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = Get-TestCaseValue -ScopeName 'HttpHeaders' -TestCaseName 'Invalid' -First 1
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },

                # @{ # No validation for 'HttpBody' to deem it invalid at present.
                #     ApiUri = $validApiUri
                #     HttpMethod = $validHttpMethod
                #     HttpHeaders = $validHttpHeaders
                #     HttpBody = Get-TestCaseValue -ScopeName 'HttpBody' -TestCaseName 'Invalid' -First 1
                #     HttpContentType = $validHttpContentType
                #     RetryAttempts = $validRetryAttempts
                #     RetryIntervalMs = $validRetryIntervalMs
                # },

                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = Get-TestCaseValue -ScopeName 'HttpContentType' -TestCaseName 'Invalid' -First 1
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = $validRetryIntervalMs
                },

                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = Get-TestCaseValue -ScopeName 'RetryAttempts' -TestCaseName 'Invalid' -First 1
                    RetryIntervalMs = $validRetryIntervalMs
                },

                @{
                    ApiUri = $validApiUri
                    HttpMethod = $validHttpMethod
                    HttpHeaders = $validHttpHeaders
                    HttpBody = $validHttpBody
                    HttpContentType = $validHttpContentType
                    RetryAttempts = $validRetryAttempts
                    RetryIntervalMs = Get-TestCaseValue -ScopeName 'RetryIntervalMs' -TestCaseName 'Invalid' -First 1
                }


            )
        }
    }

    [int]$testCaseOffset = 0
    $testCases = $ParameterSetTestCases[$CommandName][$ParameterSetName][$TestCaseName] | ForEach-Object {
        @{
            ParameterSetValuesOffset = $testCaseOffset
            ParameterSetValuesKey = $_.Keys -join ','
            ParameterSetValues = $_
        }
        $testCaseOffset++
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
