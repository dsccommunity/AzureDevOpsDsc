
Describe "[AzDevOpsApiDscResourceBase]::GetResourceKeyPropertyName() tests" -Tag 'Unit', 'AzDevOpsApiDscResourceBase'  {


    Context 'When called from instance of the class with the correct/expected, DSC Resource prefix' {

        class AzDevOpsApiDscResourceBaseWithKey : AzDevOpsApiDscResourceBase
        {
            [System.String]$ApiDscResourceBaseId

            [DscProperty(Key)]
            [System.String]$ApiDscResourceBaseKey
        }

        It 'Should not throw' {

            $azDevOpsApiDscResourceBaseWithKey = [AzDevOpsApiDscResourceBaseWithKey]@{
                ApiDscResourceBaseId  = 'ApiDscResourceBaseIdValue'
                ApiDscResourceBaseKey = 'ApiDscResourceBaseKeyValue'
            }

            {$azDevOpsApiDscResourceBaseWithKey.GetResourceKeyPropertyName()} | Should -Not -Throw
        }

        It 'Should return the same name as the DSC Resource/class without the expected prefix' {

            $azDevOpsApiDscResourceBaseWithKey = [AzDevOpsApiDscResourceBaseWithKey]@{
                ApiDscResourceBaseId  = 'ApiDscResourceBaseIdValue'
                ApiDscResourceBaseKey = 'ApiDscResourceBaseKeyValue'
            }

            $azDevOpsApiDscResourceBaseWithKey.GetResourceKeyPropertyName() | Should -Be 'ApiDscResourceBaseKey'
        }
    }
}

