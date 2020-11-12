<#
    .SYNOPSIS
        Waits for an Azure DevOps API resource to be present or absent.

        NOTE: Use of one of the '-IsPresent' or '-IsAbsent' switch is required.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER ApiVersion
        The version of the Azure DevOps API to use in the call/execution to/against the API.

    .PARAMETER Pat
        The 'Personal Access Token' (PAT) to be used by any subsequent requests/operations
        against the Azure DevOps API. This PAT must have the relevant permissions assigned
        for the subsequent operations being performed.

    .PARAMETER ResourceName
        The name of the resource being updated within Azure DevOps (e.g. 'Project')

    .PARAMETER ResourceId
        The 'id' of the Azure DevOps API Resource. This is typically obtained from a response
        provided by the API when a request is made to it.

    .PARAMETER IsPresent
        Use of this switch will ensure the function waits for the Azure DevOps API resource
        to be present.

        Failure to use this switch or the '-IsAbsent' one as an alternative will throw an
        exception. An exception will also be thrown if the wait exceeds the timeout.

    .PARAMETER IsAbsent
        Use of this switch will ensure the function waits for the Azure DevOps API resource
        to be absent.

        Failure to use this switch or the '-IsPresent' one as an alternative will throw an
        exception. An exception will also be thrown if the wait exceeds the timeout.

    .EXAMPLE
        Wait-AzDevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' `
                                 -ResourceName 'YourResourceName' -ResourceId 'YourResourceId' `
                                 -IsPresent

        Waits for the Azure DevOps 'Resource' (identified by the 'ResourceId' for the specific 'ResourceName')
        to indicate that the API resource being waited for is present (i.e. it has been added and does exist).

    .EXAMPLE
        Wait-AzDevOpsApiResource -ApiUri 'YourApiUriHere' -Pat 'YourPatHere' `
                                 -ResourceName 'YourResourceName' -ResourceId 'YourResourceId' `
                                 -IsAbsent

        Waits for the Azure DevOps 'Resource' (identified by the 'ResourceId' for the specific 'ResourceName')
        to indicate that the API resource being waited for is absent (i.e. it has been removed and does not exist).
#>
function Wait-AzDevOpsApiResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateScript( { Test-AzDevOpsApiUri -ApiUri $_ -IsValid })]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter()]
        [ValidateScript( { Test-AzDevOpsApiVersion -ApiVersion $_ -IsValid })]
        [System.String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default),

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-AzDevOpsPat -Pat $_ -IsValid })]
        [Alias('PersonalAccessToken')]
        [System.String]
        $Pat,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-AzDevOpsApiResourceName -ResourceName $_ -IsValid })]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-AzDevOpsApiResourceId -ResourceId $_ -IsValid })]
        [Alias('Id')]
        [System.String]
        $ResourceId,

        [Parameter()]
        [ValidateRange(250,10000)]
        [Alias('Interval','IntervalMilliseconds')]
        [System.Int32]
        $WaitIntervalMilliseconds = $(Get-AzDevOpsApiWaitIntervalMs),

        [Parameter()]
        [ValidateRange(250,10000)]
        [Alias('Timeout','TimeoutMilliseconds')]
        [System.Int32]
        $WaitTimeoutMilliseconds = $(Get-AzDevOpsApiWaitTimeoutMs),

        [Parameter(Mandatory = $true, ParameterSetName='IsPresent')]
        [ValidateSet($true)]
        [System.Management.Automation.SwitchParameter]
        $IsPresent,

        [Parameter(Mandatory = $true, ParameterSetName='IsAbsent')]
        [ValidateSet($true)]
        [System.Management.Automation.SwitchParameter]
        $IsAbsent
    )

    if (!$IsPresent -and !$IsAbsent)
    {
        $errorMessage = $script:localizedData.MandatoryIsPresentAndIsAbsentSwitchesNotUsed -f $MyInvocation.MyCommand
        New-InvalidOperationException -Message $errorMessage
    }
    elseif ($IsPresent -and $IsAbsent)
    {
        $errorMessage = $script:localizedData.MandatoryIsPresentAndIsAbsentSwitchesBothUsed -f $MyInvocation.MyCommand
        New-InvalidOperationException -Message $errorMessage
    }


    [System.DateTime]$waitStartDateTime = $(Get-Date).ToUniversalTime()

    [bool]$testAzDevOpsApiResource = Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat `
                                                              -ResourceName $ResourceName `
                                                              -ResourceId $ResourceId

    # Wait/Sleep while...
    # 1) Resource is currently absent but waiting for presence or;
    # 2) Resource is currently present but waiting for absence
    while (($IsPresent -and -not $testAzDevOpsApiResource) -or
           ($IsAbsent -and $testAzDevOpsApiResource))
    {
        Start-Sleep -Milliseconds $WaitIntervalMilliseconds

        if (Test-AzDevOpsApiTimeoutExceeded -StartTime $waitStartDateTime -End $($(Get-Date).ToUniversalTime()) -TimeoutMs $WaitTimeoutMilliseconds )
        {
            $errorMessage = $script:localizedData.AzDevOpsApiResourceWaitTimeoutExceeded -f $MyInvocation.MyCommand, $ResourceName, $ResourceId, $WaitTimeoutMilliseconds
            New-InvalidOperationException -Message $errorMessage
        }

        [bool]$testAzDevOpsApiResource = Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat `
                                                                  -ResourceName $ResourceName `
                                                                  -ResourceId $ResourceId
    }
}
