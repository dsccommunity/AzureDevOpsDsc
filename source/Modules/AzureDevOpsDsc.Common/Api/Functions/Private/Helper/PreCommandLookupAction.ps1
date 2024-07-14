<#
$ExecutionContext.InvokeCommand.PreCommandLookupAction = {
    param($command, $commandScriptBlock)

    #
    # If the Command is 'Add-AuthenticationHTTPHeader' and is called outside of 'Invoke-AzDevOpsApiRestMethod' function

    if ($command -eq 'Add-AuthenticationHTTPHeader' -and $MyInvocation.MyCommand.Name -ne 'Invoke-AzDevOpsApiRestMethod')
    {
        throw "The function 'Add-AuthenticationHTTPHeader' can only be called inside of 'Invoke-AzDevOpsApiRestMethod' function."
    }

    #
    # Any export function used within Invoke-AzDevOpsApiRestMethod is not allowed.

    if ($command -match 'Export-')
    {
        throw "The command '$command' is not allowed to be used within 'Invoke-AzDevOpsApiRestMethod' function."
    }

    #
    # Any attempt of using [System.Runtime.InteropServices.Marshal] outside of 'AuthenticationToken' class is not allowed.

    if ($command -match 'System.Runtime.InteropServices.Marshal' -and $MyInvocation.MyCommand.Name -ne 'AuthenticationToken')
    {
        throw "The command '$command' is not allowed to be used outside of 'AuthenticationToken' class."
    }

}
#>
