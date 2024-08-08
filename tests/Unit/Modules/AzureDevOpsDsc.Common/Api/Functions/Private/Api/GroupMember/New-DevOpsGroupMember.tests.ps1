powershell
Describe "New-DevOpsGroupMember Tests" {
    Mock Get-AzDevOpsApiVersion { return "6.0-preview.1" }
    Mock Invoke-AzDevOpsApiRestMethod

    $GroupIdentity = [pscustomobject]@{ descriptor = "vssgp.Uy8yNTarDUI1LTE4N" }
    $MemberIdentity = [pscustomobject]@{ descriptor = "aad.MjU2ZDQtNzQtNDAwOA" }
    $ApiUri = "https://dev.azure.com/myorg"

    Context "When all mandatory parameters are provided" {
        It "Calls Invoke-AzDevOpsApiRestMethod with constructed URI and method" {
            $result = New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri

            $expectedUri = "{0}/_apis/graph/memberships/{1}/{2}?api-version={3}" -f $ApiUri, $MemberIdentity.descriptor, $GroupIdentity.descriptor, "6.0-preview.1"

            Assert-MockCalled -MockName Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -Scope It -ParameterFilter { 
                $params.Uri -eq $expectedUri -and
                $params.Method -eq "PUT"
            }
        }
    }

    Context "When ApiVersion parameter is provided" {
        It "Uses the provided ApiVersion in the URI" {
            $ApiVersion = "5.1"
            $result = New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri -ApiVersion $ApiVersion

            $expectedUri = "{0}/_apis/graph/memberships/{1}/{2}?api-version={3}" -f $ApiUri, $MemberIdentity.descriptor, $GroupIdentity.descriptor, $ApiVersion

            Assert-MockCalled -MockName Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -Scope It -ParameterFilter { 
                $params.Uri -eq $expectedUri -and
                $params.Method -eq "PUT"
            }
        }
    }

    Context "When Invoke-AzDevOpsApiRestMethod throws an error" {
        Mock Invoke-AzDevOpsApiRestMethod { throw "REST call failed" } -Verifiable -Scope It
        It "Catches and writes an error" {
            { New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri } | Should -Throw

            Assert-MockCalled -MockName Invoke-AzDevOpsApiRestMethod -Times 1 -Exactly -Scope It
        }
    }

    Context "When Get-AzDevOpsApiVersion is called" {
        It "Calls Get-AzDevOpsApiVersion to get the default ApiVersion" {
            New-DevOpsGroupMember -GroupIdentity $GroupIdentity -MemberIdentity $MemberIdentity -ApiUri $ApiUri

            Assert-MockCalled -MockName Get-AzDevOpsApiVersion -Times 1 -Exactly -Scope It
        }
    }
}

