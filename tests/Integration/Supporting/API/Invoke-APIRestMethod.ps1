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
        $NoAuthentication,

        [Parameter()]
        [Switch]
        $AzureArcAuthentication

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

    if ($null -eq $HttpHeaders.Authorization)
    {
        $HttpHeaders.Authorization = Add-Header
    }

    #
    # Invoke the REST method
    try
    {
        # Invoke the REST method. If the 'Verbose' switch is present, set it to $false.
        # This is to prevent the output from being displayed in the console.
        $response = Invoke-RestMethod @invokeRestMethodParameters -Verbose:$false
        return $response
    }
    catch
    {
        # If AzureArcAuthentication is present, then we need to handle the error differently.
        # Stop and Pass the error back to the caller. The caller will handle the error.
        if ($AzureArcAuthentication.IsPresent)
        {
            throw $_
        }

        # Wait before the next attempt/retry
        Start-Sleep -Milliseconds $RetryIntervalMs

        # Break the continuation token loop so that the next attempt can be made
        break;

    }

}
