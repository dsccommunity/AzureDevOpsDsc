

Class AuthenticationToken {

    hidden [TokenType]$tokenType
    hidden [bool]$linux = $isLinux

    # Function to convert a SecureString to a String
    hidden [String]ConvertFromSecureString([SecureString]$SecureString) {
        # Convert a SecureString to a String
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $String = ($this.linux) ? [System.Runtime.InteropServices.Marshal]::PtrToStringUni($BSTR) :
                                  [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        return $String
    }

    # Function to test the call stack
    hidden [Bool]TestCallStack([String]$name) {

        # Get the call stack
        Write-Verbose "[AuthenticationToken] Getting the call stack."

        $CallStack = Get-PSCallStack

        # Check if any of the callers in the call stack is Invoke-DSCResource
        foreach ($stackFrame in $callStack) {
            if ($stackFrame.Command -eq $name) {
                Write-Verbose "[AuthenticationToken] The calling function is $name."
                return $true
            }
        }

        return $false

    }

    # Function to prevent unauthorized access to the Get() method
    TestCaller() {
        #
        # Prevent Execution and Writing to Files and Pipeline Variables.

        # Token can only be called within Test-AzAuthenticationToken. Test to see if the calling function is Test-AzAuthenticationToken
        if ((-not($this.TestCallStack('Add-AuthenticationHTTPHeader'))) -and (-not($this.TestCallStack('Invoke-AzDevOpsApiRestMethod')))) {
            # Token can only be called within Invoke-AzDevOpsApiRestMethod. Test to see if the calling function is Invoke-AzDevOpsApiRestMethod
            throw "[AuthenticationToken][Access Denied] The Get() method can only be called within AzureDevOpsDsc.Common."
        }

        # Token cannot be returned within a Write-* function. Test to see if the calling function is Write-*
        if ($this.TestCallStack('Write-')) { throw "[AuthenticationToken][Access Denied] The Get() method cannot be called within a Write-* function." }
        # Token cannot be written to a file. Test to see if the calling function is Out-File
        if ($this.TestCallStack('Out-File')) { throw "[AuthenticationToken][Access Denied] The Get() method cannot be called within Out-File." }

    }

    # Return the access token
    [String] Get() {

        # Verbose output
        Write-Verbose "[AuthenticationToken] Getting the access token:"
        Write-Verbose "[AuthenticationToken] Ensuring that the calling function is allowed to call the Get() method."

        # Test the caller
        $this.TestCaller()

        Write-Verbose "[AuthenticationToken] Token Retrival Successful."

        # Return the access token
        return ($this.ConvertFromSecureString($this.access_token))

    }

}
