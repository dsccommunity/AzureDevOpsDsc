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

        [Parameter()]
        [ValidateScript( { Test-AzDevOpsApiHttpRequestHeader -HttpRequestHeader $_ -IsValid })]
        [Hashtable]
        [Alias('Headers','HttpRequestHeader')]
        $HttpHeaders=@{},

        [Parameter()]
        [System.String]
        [Alias('Body')]
        $HttpBody,

        [Parameter()]
        [System.String]
        [Alias('ContentType')]
        [ValidateSet('application/json','application/json-patch+json')]
        $HttpContentType = 'application/json',

        [Parameter()]
        [ValidateRange(0,5)]
        [Int32]
        $RetryAttempts = 5,

        [Parameter()]
        [ValidateRange(250,10000)]
        [Int32]
        $RetryIntervalMs = 250,

        [Parameter()]
        [String]
        $ApiVersion = $(Get-AzDevOpsApiVersion -Default),

        [Parameter()]
        [Switch]
        $NoAuthentication

    )

    $invokeRestMethodParameters = @{
        Uri                         = $ApiUri
        Method                      = $HttpMethod
        Headers                     = $HttpHeaders
        Body                        = $HttpBody
        ContentType                 = $HttpContentType
        ResponseHeadersVariable     = 'responseHeaders'
    }

    Write-Verbose -Message ("[Invoke-AzDevOpsApiRestMethod] Invoking the Azure DevOps API REST method '{0}'." -f $HttpMethod)
    Write-Verbose -Message ("[Invoke-AzDevOpsApiRestMethod] API URI: {0}" -f $ApiUri)

    # Remove the 'Body' and 'ContentType' if not relevant to request
    if ($HttpMethod -in $('Get','Delete'))
    {
        $invokeRestMethodParameters.Remove('Body')
        $invokeRestMethodParameters.Remove('ContentType')
    }

    # Intially set this value to -1, as the first attempt does not want to be classed as a "RetryAttempt"
    $CurrentNoOfRetryAttempts = -1
    # Set the Continuation Token to be False
    $isContinuationToken = $false
    $results = [System.Collections.ArrayList]::new()

    while ($CurrentNoOfRetryAttempts -lt $RetryAttempts)
    {

        #
        # Slow down the retry attempts if the API resource is close to being overwelmed

        # If there are any retry attempts, wait for the specified number of seconds before retrying
        if (($null -ne $Global:DSCAZDO_APIRateLimit.xRateLimitRemaining) -and ($Global:DSCAZDO_APIRateLimit.retryAfter -ge 0))
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
        # Invoke the REST method. Loop until the Continuation Token is False.

        Do {

            #
            # Add the Authentication Header

            # If the 'NoAuthentication' switch is NOT PRESENT and the 'Authentication' header is empty, add the authentication header
            if (([String]::IsNullOrEmpty($invokeRestMethodParameters.Headers.Authentication)) -and (-not $NoAuthentication.IsPresent))
            {
                $invokeRestMethodParameters.Headers.Authorization = Add-AuthenticationHTTPHeader
            }

            #
            # Invoke the REST method

            try
            {

                $invokeRestMethodParameters | Export-Clixml C:\Temp\invokeRestMethodParameters.clixml

                $response = Invoke-RestMethod @invokeRestMethodParameters
                # Add the response to the results array
                $null = $results.Add($response)

                #
                # Test to see if there is no continuation token
                if ([String]::IsNullOrEmpty($responseHeaders.'x-ms-continuationtoken'))
                {
                    # If not, set the continuation token to False
                    $isContinuationToken = $false
                    # Update the Rate Limit information
                    $Global:DSCAZDO_APIRateLimit = $null

                    Write-Verbose "[Invoke-AzDevOpsApiRestMethod] No continuation token found. Breaking loop."

                    return $results

                }

                #
                # A continuation token is present.

                # If so, set the continuation token to True
                $isContinuationToken = $true
                # Update the URI to include the continuation token
                $invokeRestMethodParameters.Uri = '{0}&continuationToken={1}&{2}' -f $ApiUri, $responseHeaders.'x-ms-continuationtoken', $ApiVersion
                # Reset the RetryAttempts counter
                $CurrentNoOfRetryAttempts = -1

            }
            catch
            {

                # Check to see if it is an HTTP 429 (Too Many Requests) error
                if ($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::TooManyRequests)
                {
                    # If so, wait for the specified number of seconds before retrying
                    $retryAfter = $_.Exception.Response.Headers | ForEach-Object { if ($_.Key -eq "Retry-After") { return $_.Value } }
                    if ($retryAfter)
                    {
                        $retryAfter = [int]$retryAfter
                        Write-Verbose -Message "Received a 'Too Many Requests' response from the Azure DevOps API. Waiting for $retryAfter seconds before retrying."
                        $Global:DSCAZDO_APIRateLimit = [APIRateLimit]::New($retryAfter)
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

                # Break the continuation token loop so that the next attempt can be made
                break;

            }

        } Until (-not $isContinuationToken)

    }

    # If all retry attempts have failed, throw an exception
    $errorMessage = $script:localizedData.AzDevOpsApiRestMethodException -f $MyInvocation.MyCommand, $RetryAttempts, $restMethodExceptionMessage
    New-InvalidOperationException -Message $errorMessage -Throw

}
