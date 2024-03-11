<#
    .SYNOPSIS
        This is a light, generic, wrapper proceedure around 'Invoke-RestMethod' to handle
        multiple retries and error/exception handling.

        This function makes no assumptions around the versions of the API used, the resource
        being operated/actioned upon, the operation/method being performed, nor the content
        of the HTTP headers and body.

    .PARAMETER ApiUri
        The URI of the Azure DevOps API to be connected to. For example:

          https://dev.azure.com/someOrganizationName/_apis/

    .PARAMETER HttpMethod
        The HTTP method being used in the HTTP/REST request sent to the Azure DevOps API.

    .PARAMETER HttpHeaders
        The headers for the HTTP/REST request sent to the Azure DevOps API.

    .PARAMETER HttpBody
        The body for the HTTP/REST request sent to the Azure DevOps API. If performing a 'Post',
        'Put' or 'Patch' method/request, this will typically contain the JSON document of the resource.

    .PARAMETER RetryAttempts
        The number of times the method/request will attempt to be resent/retried if unsuccessful on the
        initial attempt.

        If any attempt is successful, the remaining attempts are ignored.

    .PARAMETER RetryIntervalMs
        The interval (in Milliseconds) between retry attempts.

    .EXAMPLE
        Invoke-AzDevOpsApiRestMethod -ApiUri 'YourApiUriHere' -HttpMethod 'Get' -HttpHeaders $YouHttpHeadersHashtableHere

        Submits a 'Get' request to the Azure DevOps API (relying on the 'ApiUri' value to determine what is being retrieved).

    .EXAMPLE
        Invoke-AzDevOpsApiRestMethod -ApiUri 'YourApiUriHere' -HttpMethod 'Patch' -HttpHeaders $YourHttpHeadersHashtableHere `
                                     -HttpBody $YourHttpBodyHere -RetryAttempts 3

        Submits a 'Patch' request to the Azure DevOps API with the supplied 'HttpBody' and will attempt to retry 3 times (4 in
        total, including the intitial attempt) if unsuccessful.
#>
function Invoke-AzDevOpsApiRestMethod
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(Mandatory=$true)]
        [Alias('Uri')]
        [System.String]
        $ApiUri,

        [Parameter(Mandatory=$true)]
        [ValidateSet('Get','Post','Patch','Put','Delete')]
        [System.String]
        [Alias('Method')]
        $HttpMethod,

        [Parameter(Mandatory=$true)]
        [ValidateScript( { Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $_ -IsValid })]
        [Hashtable]
        [Alias('Headers','HttpRequestHeader')]
        $HttpHeaders,

        [Parameter()]
        [System.String]
        [Alias('Body')]
        $HttpBody,

        [Parameter()]
        [System.String]
        [Alias('ContentType')]
        [ValidateSet('application/json')]
        $HttpContentType = 'application/json',

        [Parameter()]
        [ValidateRange(0,5)]
        [Int32]
        $RetryAttempts = 5,

        [Parameter()]
        [ValidateRange(250,10000)]
        [Int32]
        $RetryIntervalMs = 250
    )

    $invokeRestMethodParameters = @{
        Uri                         = $ApiUri
        Method                      = $HttpMethod
        Headers                     = $HttpHeaders
        Body                        = $HttpBody
        ContentType                 = $HttpContentType
        ResponseHeadersVariable     = 'responseHeaders'
    }

    # Remove the 'Body' and 'ContentType' if not relevant to request
    if ($HttpMethod -in $('Get','Delete'))
    {
        $invokeRestMethodParameters.Remove('Body')
        $invokeRestMethodParameters.Remove('ContentType')
    }

    # Intially set this value to -1, as the first attempt does not want to be classed as a "RetryAttempt"
    $CurrentNoOfRetryAttempts = -1

    while ($CurrentNoOfRetryAttempts -lt $RetryAttempts)
    {

        #
        # Slow down the retry attempts if the API resource is close to being overwelmed

        # If there are any retry attempts, wait for the specified number of seconds before retrying
        if ($Global:DSCAZDO_APIRateLimit.retryAfter -ge 0)
        {
            Write-Verbose -Message ("[Invoke-AzDevOpsApiRestMethod] Waiting for {0} seconds before retrying." -f $Global:DSCAZDO_APIRateLimit.retryAfter)
            Start-Sleep -Seconds $Global:DSCAZDO_APIRateLimit.retryAfter
        }

        # If the API resouce is close to beig overwelmed, wait for the specified number of seconds before sending the request
        if (($null -ne $Global:DSCAZDO_APIRateLimit.xRateLimitRemaining) -and ($Global:DSCAZDO_APIRateLimit.xRateLimitRemaining -le 50) -and ($Global:DSCAZDO_APIRateLimit.xRateLimitRemaining -ge 5))
        {
            Write-Verbose -Message "[Invoke-AzDevOpsApiRestMethod] Resource is close to being overwelmed. Waiting for $RetryIntervalMs seconds before sending the request."
            Start-Sleep -Milliseconds $RetryIntervalMs
        }
        # If the API resouce is overwelmed, wait for the specified number of seconds before sending the request
        elseif (($null -ne $Global:DSCAZDO_APIRateLimit.xRateLimitRemaining) -and ($Global:DSCAZDO_APIRateLimit.xRateLimitRemaining -lt 5))
        {
            Write-Verbose -Message ("[Invoke-AzDevOpsApiRestMethod] Resource is overwelmed. Waiting for {0} seconds to reset the TSTUs." -f $Global:DSCAZDO_APIRateLimit.xRateLimitReset)
            Start-Sleep -Milliseconds $RetryIntervalMs
        }

        #
        # Test if a Managed Identity Token is required and if so, add it to the HTTP Headers
        if ($Global:DSCAZDO_ManagedIdentityToken -ne $null)
        {
            # Test if the Managed Identity Token has expired
            if ($Global:DSCAZDO_ManagedIdentityToken.isExpired())
            {
                # If so, get a new token
                $Global:DSCAZDO_ManagedIdentityToken = Update-AzManagedIdentityToken -OrganizationName $Global:DSCAZDO_OrganizationName
            }

            # Add the Managed Identity Token to the HTTP Headers
            $invokeRestMethodParameters.Headers.Authorization = 'Bearer {0}' -f $Global:DSCAZDO_ManagedIdentityToken.Get()
        }


        #
        # Invoke the REST method

        try
        {
            $result = Invoke-RestMethod @invokeRestMethodParameters

            # Update
            $Global:DSCAZDO_APIRateLimit = $null
            return $result

        }
        catch
        {

            # Check to see if it is an HTTP 429 (Too Many Requests) error
            if ($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::TooManyRequests)
            {
                # If so, wait for the specified number of seconds before retrying
                $retryAfter = $_.Exception.Response.Headers.'Retry-After'
                if ($retryAfter)
                {
                    $retryAfter = [int]$retryAfter
                    Write-Verbose -Message "Received a 'Too Many Requests' response from the Azure DevOps API. Waiting for $retryAfter seconds before retrying."
                    $Global:DSCAZDO_APIRateLimit = [APIRateLimit]::New($_.Exception.Response.Headers)
                } else {
                    # If the Retry-After header is not present, wait for the specified number of milliseconds before retrying
                    Write-Verbose -Message "Received a 'Too Many Requests' response from the Azure DevOps API. Waiting for $RetryIntervalMs milliseconds before retrying."
                    $Global:DSCAZDO_APIRateLimit = [APIRateLimit]::New($RetryIntervalMs)
                }

            }

            # Increment the number of retries attempted and obtain any exception message
            $CurrentNoOfRetryAttempts++
            $restMethodExceptionMessage = $_.Exception.Message

            # Wait before the next attempt/retry
            Start-Sleep -Milliseconds $RetryIntervalMs
        }
    }


    # If all retry attempts have failed, throw an exception
    $errorMessage = $script:localizedData.AzDevOpsApiRestMethodException -f $MyInvocation.MyCommand, $RetryAttempts, $restMethodExceptionMessage
    New-InvalidOperationException -Message $errorMessage

}
