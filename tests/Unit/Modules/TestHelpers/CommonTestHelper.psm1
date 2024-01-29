

<#
    .SYNOPSIS
        Returns $true if the the environment variable APPVEYOR is set to $true,
        and the environment variable CONFIGURATION is set to the value passed
        in the parameter Type.

    .PARAMETER Name
        Name of the test script that is called. Default value is the name of the
        calling script.

    .PARAMETER Type
        Type of tests in the test file. Can be set to Unit or Integration.

    .PARAMETER Category
        Optional. One or more categories to check if they are set in
        $env:CONFIGURATION. If this are not set, the parameter Type
        is used as category.
#>
function Test-BuildCategory
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name = $MyInvocation.PSCommandPath.Split('\')[-1],

        [Parameter(Mandatory = $true)]
        [ValidateSet('Unit', 'Integration')]
        [System.String]
        $Type,

        [Parameter()]
        [System.String[]]
        $Category
    )

    # Support using only the Type parameter as category names.
    if (-not $Category)
    {
        $Category = @($Type)
    }

    $result = $true

    if ($Type -eq 'Integration' -and -not $env:CI -eq $true)
    {
        Write-Warning -Message ('{1} test for {0} will be skipped unless $env:CI is set to $true' -f $Name, $Type)
        $result = $false
    }

    <#
        If running in CI then check if it should run in the
        current category set in $env:CONFIGURATION.
    #>
    if ($env:CI -eq $true -and -not (Test-ContinuousIntegrationTaskCategory -Category $Category))
    {
        Write-Verbose -Message ('{1} tests in {0} will be skipped unless $env:CONFIGURATION is set to ''{1}''.' -f $Name, ($Category -join ''', or ''')) -Verbose
        $result = $false
    }

    return $result
}

<#
    .SYNOPSIS
        Returns $true if the the environment variable APPVEYOR is set to $true,
        and the environment variable CONFIGURATION is set to the value passed
        in the parameter Type.

    .PARAMETER Category
        One or more categories to check if they are set in $env:CONFIGURATION.
#>
function Test-ContinuousIntegrationTaskCategory
{
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Category
    )

    $result = $false

    if ($env:CI -eq $true -and $env:CONFIGURATION -in $Category)
    {
        $result = $true
    }

    return $result
}

<#
    .SYNOPSIS
        Returns the parameters relating to a command.

    .PARAMETER CommandName
        The name of the command to retrieve the parameters.

    .PARAMETER ModuleName
        The name of the module the command belongs to.
#>
function Get-CommandParameter
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $true)]
        [System.String]
        $CommandName,

        [Parameter()]
        [System.String]
        $ModuleName = '*'
    )

    Get-Command -Module $ModuleName -Name $CommandName |
        ForEach-Object { if ($_.Parameters) {$_.Parameters.Values }}

}

<#
    .SYNOPSIS
        Returns the aliases relating to a command and it's parameters.

    .PARAMETER CommandName
        The name of the command to retrieve the parameter aliases.

    .PARAMETER ParameterName
        The name of the parameter to retrieve the aliases of.

    .PARAMETER ModuleName
        The name of the module the command belongs to.
#>
function Get-CommandParameterAlias
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $true)]
        [System.String]
        $CommandName,

        [Parameter()]
        [System.String]
        $ParameterName = '*',

        [Parameter()]
        [System.String]
        $ModuleName = '*'
    )

    Get-CommandParameter -CommandName $CommandName -ModuleName $ModuleName |
        ForEach-Object { if ($_.Name -ilike $ParameterName -and $_.Aliases) {$_.Aliases }}

}



<#
    .SYNOPSIS
        Returns the parameter sets relating to a command.

    .PARAMETER CommandName
        The name of the command to retrieve the parameter sets.

    .PARAMETER ModuleName
        The name of the module the command belongs to.

#>
function Get-CommandParameterSet
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $true)]
        [Alias('TestAlias')]
        [System.String]
        $CommandName,

        [Parameter()]
        [System.String]
        $ModuleName = '*'

    )


    [hashtable]$command = $(Get-Command -Module $ModuleName -Name $CommandName -ErrorAction SilentlyContinue)
    if ($null -eq $command)
    {
        $Module = Get-Module -Name $ModuleName -ListAvailable
        If ($null -ne $Module)
        {
            $allCommands = $Module.Invoke({Get-Command -Module $ModuleName})
            $exportedCommands = Get-Command -Module $ModuleName
            $command = $(Compare-Object -ReferenceObject $allCommands -DifferenceObject $exportedCommands |
                Select-Object -ExpandProperty InputObject)
        }
    }

    if ($null -ne $command -and $null -ne $command.ParameterSets)
    {
        return $command.ParameterSets
    }

}

<#
    .SYNOPSIS
        Returns the parameter sets relating to a parameter set of a command.

    .PARAMETER CommandName
        The name of the command to retrieve the parameter sets.

    .PARAMETER ParameterSetName
        The name of the parameter set of the command to retrieve the parameters for.

    .PARAMETER ModuleName
        The name of the module the command belongs to.

#>
function Get-CommandParameterSetParameter
{
    [CmdletBinding()]
    param
    (
        [Parameter( Mandatory = $true)]
        [Alias('TestAlias')]
        [System.String]
        $CommandName,

        [Parameter()]
        [System.String]
        $ParameterSetName = '*',

        [Parameter()]
        [System.String]
        $ModuleName = '*'

    )

    $($(Get-CommandParameterSet -CommandName $CommandName -ModuleName $ModuleName) |
        Where-Object { $_.Name -like $ParameterSetName}).Parameters

}


function Set-OutputDirAsModulePath
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $RepositoryRoot
    )

    # Set the module path if it is not already set
    if ($ENV:PSModulePath -like "*$($RepositoryRoot)*") { return }

    $ModulePath = '{0}{1}\' -f (($IsLinux) ? ':' : ';'), $RepositoryRoot
    $ENV:PSModulePath = "{0}{1}\output" -f $ENV:PSModulePath, $ModulePath
    $ENV:PSModulePath = "{0}{1}\output\AzureDevOpsDsc\0.0.0\Modules" -f $ENV:PSModulePath, $ModulePath

}
