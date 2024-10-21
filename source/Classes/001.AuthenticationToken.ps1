<#
    .SYNOPSIS
        Represents an authentication token with methods to manage and retrieve the token securely.

    .DESCRIPTION
        The AuthenticationToken class encapsulates an authentication token, providing methods to convert a SecureString to a String,
        test the call stack for specific functions, and ensure that the Get() method is called only by authorized functions.

    .PROPERTIES
        [TokenType]$tokenType
            The type of the token.

        hidden [bool]$linux
            Indicates if the environment is Linux.

        hidden [SecureString]$access_token
            The secure access token.

    .METHODS
        hidden [String] ConvertFromSecureString([SecureString]$SecureString)
            Converts a SecureString to a plain String.

        hidden [Bool] TestCallStack([String]$name)
            Tests the call stack to check if a specific function is in the call stack.

        TestCaller()
            Ensures that the Get() method is called only by authorized functions and not within certain contexts.

        [String] Get()
            Retrieves the access token after ensuring that the calling function is authorized to do so.

    .NOTES
        The class is designed to prevent unauthorized access to the access token and to ensure that the token is handled securely.
#>

class AuthenticationToken
{
    [TokenType] $tokenType
    hidden [bool] $linux = $isLinux
    hidden [SecureString] $access_token

    # Function to convert a SecureString to a String
    hidden [String] ConvertFromSecureString([SecureString] $SecureString)
    {
        # Convert a SecureString to a String
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $plainTextString = $(
            if ($this.linux)
            {
                [System.Runtime.InteropServices.Marshal]::PtrToStringUni($BSTR)
            } else {
                [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            }
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        )
        return $plainTextString

    }

    # Function to test the call stack
    hidden [Bool] TestCallStack([String] $name)
    {
        # Get the call stack
        Write-Verbose "[AuthenticationToken] Getting the call stack."
        $CallStack = Get-PSCallStack

        # Check if any of the callers in the call stack is Invoke-DSCResource
        foreach ($stackFrame in $CallStack)
        {
            if ($stackFrame.Command -eq $name)
            {
                Write-Verbose "[AuthenticationToken] The calling function is $name."
                return $true
            }
        }
        return $false
    }

    # Function to prevent unauthorized access to the Get() method
    TestCaller()
    {
        # Prevent Execution and Writing to Files and Pipeline Variables.

        <#
            The Get() method can only be called within the following functions:
            - Add-AuthenticationHTTPHeader
            - Invoke-AzDevOpsApiRestMethod
            - New-AzDoAuthenticationProvider
        #>
        if (
            (-not($this.TestCallStack('Add-AuthenticationHTTPHeader'))) -and
            (-not($this.TestCallStack('Invoke-AzDevOpsApiRestMethod'))) -and
            (-not($this.TestCallStack('New-AzDoAuthenticationProvider')))
        )
        {
            # Token can only be called within Invoke-AzDevOpsApiRestMethod. Test to see if the calling function is Invoke-AzDevOpsApiRestMethod
            throw "[AuthenticationToken][Access Denied] The Get() method can only be called within AzureDevOpsDsc.Common."
        }

        # Token cannot be returned within a Write-* function. Test to see if the calling function is Write-*
        if ($this.TestCallStack('Write-'))
        {
            throw "[AuthenticationToken][Access Denied] The Get() method cannot be called within a Write-* function."
        }

        # Token cannot be written to a file. Test to see if the calling function is Out-File
        if ($this.TestCallStack('Out-File'))
        {
            throw "[AuthenticationToken][Access Denied] The Get() method cannot be called within Out-File."
        }
    }

    # Return the access token
    [String] Get()
    {
        # Verbose output
        Write-Verbose "[AuthenticationToken] Getting the access token:"
        Write-Verbose "[AuthenticationToken] Ensuring that the calling function is allowed to call the Get() method."

        # Test the caller
        $this.TestCaller()

        Write-Verbose "[AuthenticationToken] Token Retrieval Successful."

        # Return the access token
        return ($this.ConvertFromSecureString($this.access_token))
    }
}
