

class ManagedIdentityToken {

    [SecureString]$access_token
    [DateTime]$expires_on
    [Int]$expires_in
    [String]$resource
    [String]$token_type
    hidden [bool]$linux = $IsLinux

    # Constructor
    ManagedIdentityToken([PSCustomObject]$ManagedIdentityTokenObj) {

        # Validate that ManagedIdentityTokenObj is a HashTable and Contains the correct keys
        if (-not $this.isValid($ManagedIdentityTokenObj)) { throw "The ManagedIdentityTokenObj is not valid." }

        $epochStart = [datetime]::new(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)

        # Set the properties of the class
        $this.access_token  = $ManagedIdentityTokenObj.access_token | ConvertTo-SecureString -AsPlainText -Force
        $this.expires_on    = $epochStart.AddSeconds($ManagedIdentityTokenObj.expires_on)
        $this.expires_in    = $ManagedIdentityTokenObj.expires_in
        $this.resource      = $ManagedIdentityTokenObj.resource
        $this.token_type    = $ManagedIdentityTokenObj.token_type

    }

    # Function to validate the ManagedIdentityTokenObj
    Hidden [Bool]isValid($ManagedIdentityTokenObj) {

        # Assuming these are the keys we expect in the hashtable
        $expectedKeys = @('access_token', 'expires_on', 'expires_in', 'resource', 'token_type')

        # Check if all expected keys exist in the hashtable
        foreach ($key in $expectedKeys) {
            if (-not $ManagedIdentityTokenObj."$key") {
                Write-Verbose "[ManagedIdentityToken] The hashtable does not contain the expected property: $key"
                return $false
            }
        }

        # If all checks pass, return true
        Write-Verbose "[ManagedIdentityToken] The hashtable is valid and contains all the expected keys."
        return $true
    }

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

        $CallStack = Get-PSCallStack

        # Check if any of the callers in the call stack is Invoke-DSCResource
        foreach ($stackFrame in $callStack) {
            if ($stackFrame.Command -eq $name) {
                Write-Verbose "[ManagedIdentityToken] The calling function is $name."
                return $true
            }
        }

        return $false

    }

    [Bool]isExpired() {
        # Remove 10 seconds from the expires_on time to account for clock skew.
        if ($this.expires_on.AddSeconds(-10) -lt (Get-Date)) { return $true }
        return $false
    }

    # Return the access token
    [String] Get() {

        # Prevent Execution and Writing to Files and Pipeline Variables.

        # Token can only be called within Invoke-AzDevOpsApiRestMethod. Test to see if the calling function is Invoke-AzDevOpsApiRestMethod
        if (-not($this.TestCallStack('Invoke-AzDevOpsApiRestMethod'))) { throw "[ManagedIdentityToken] The Get() method can only be called within Invoke-AzDevOpsApiRestMethod." }
        # Token cannot be returned within a Write-* function. Test to see if the calling function is Write-*
        if ($this.TestCallStack('Write-')) { throw "[ManagedIdentityToken] The Get() method cannot be called within a Write-* function." }
        # Token cannot be written to a file. Test to see if the calling function is Out-File
        if ($this.TestCallStack('Out-File')) { throw "[ManagedIdentityToken] The Get() method cannot be called within Out-File." }

        # Return the access token
        return ($this.ConvertFromSecureString($this.access_token))

    }

}

# Function to create a new ManagedIdentityToken object
Function global:New-ManagedIdentityToken ([hashtable]$ManagedIdentityTokenObj) {

    # Create and return a new ManagedIdentityToken object
    return [ManagedIdentityToken]::New($ManagedIdentityTokenObj)

}
