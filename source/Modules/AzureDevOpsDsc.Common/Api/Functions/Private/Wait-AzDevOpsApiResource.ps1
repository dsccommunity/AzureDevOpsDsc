<#
    .SYNOPSIS
        Waits for an Azure DevOps API resource to be present or absent.

        NOTE: Use of one of the '-IsPresent' or '-IsAbsent' switch is required.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

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
        [ValidateScript({ Test-AzDevOpsResourceId -ResourceId $_ -IsValid })]
        [Alias('Id')]
        [System.String]
        $ResourceId,

        [Parameter()]
        [Alias('Interval','IntervalMilliseconds')]
        [System.UInt32]
        $WaitIntervalMilliseconds = 100,

        [Parameter()]
        [Alias('Timeout','TimeoutMilliseconds')]
        [System.UInt32]
        $WaitTimeoutMilliseconds = 10000,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IsPresent,

        [Parameter()]
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


    [System.DateTime]$waitStartDateTime = [System.DateTime]::UtcNow

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

        if ($(New-TimeSpan -Start $waitStartDateTime -End $([System.DateTime]::UtcNow)).Milliseconds -gt $WaitTimeoutMilliseconds)
        {
            $errorMessage = $script:localizedData.AzDevOpsApiResourceWaitTimeoutExceeded -f $MyInvocation.MyCommand, $ResourceName, $ResourceId, $WaitTimeoutMilliseconds
            New-InvalidOperationException -Message $errorMessage
        }

        [bool]$testAzDevOpsApiResource = Test-AzDevOpsApiResource -ApiUri $ApiUri -Pat $Pat `
                                                                  -ResourceName $ResourceName `
                                                                  -ResourceId $ResourceId
    }
}
