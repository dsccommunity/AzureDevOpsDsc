Describe "New-AzDevOpsApiResource" {
    Context "When ApiVersion parameter is provided" {
        It "Should set the ApiVersion property" {
            $apiVersion = "v1"
            $resource = New-AzDevOpsApiResource -ApiVersion $apiVersion
            $resource.ApiVersion | Should Be $apiVersion
        }
    }
}
