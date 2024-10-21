
function Invoke-APIRestMethod
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
        # Invoke the REST method. Loop until the Continuation Token is False.

        Do {

            #
            # Add the Authentication Header

            # If the 'NoAuthentication' switch is NOT PRESENT and the 'Authentication' header is empty, add the authentication header
            if (([String]::IsNullOrEmpty($invokeRestMethodParameters.Headers.Authentication)) -and (-not $NoAuthentication.IsPresent))
            {
                $invokeRestMethodParameters.Headers.Authorization = Add-Header
            }

            #
            # Invoke the REST method

            try
            {
                # Invoke the REST method. If the 'Verbose' switch is present, set it to $false.
                # This is to prevent the output from being displayed in the console.
                $response = Invoke-RestMethod @invokeRestMethodParameters -Verbose:$false

                # Zero out the 'Authorization' header
                $invokeRestMethodParameters.Headers.Authorization = $null
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

                    Write-Verbose "[Invoke-APIRestMethod] No continuation token found. Breaking loop."

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
                # Zero out the 'Authorization' header
                $invokeRestMethodParameters.Headers.Authorization = $null

                # Check to see if it is an HTTP 429 (Too Many Requests) error
                if ($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::TooManyRequests)
                {
                    # If so, wait for the specified number of seconds before retrying
                    $retryAfter = $_.Exception.Response.Headers | ForEach-Object {
                        if ($_.Key -eq "Retry-After")
                        {
                            return $_.Value
                        }
                    }

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
