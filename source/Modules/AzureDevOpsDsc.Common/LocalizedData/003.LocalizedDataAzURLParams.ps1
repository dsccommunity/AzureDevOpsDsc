data LocalizedDataAzURLParams
{
@'
#
# Azure DevOps Project Services URL Parameters

ProjectService_Pipelines=ms.vss-build.pipelines
ProjectService_TestPlans=ms.vss-test-web.test
ProjectService_Boards=ms.vss-work.agile
ProjectService_Repos=ms.vss-code.version-control
ProjectService_Artifacts=ms.azure-artifacts.feature
'@ | ConvertFrom-StringData
}
