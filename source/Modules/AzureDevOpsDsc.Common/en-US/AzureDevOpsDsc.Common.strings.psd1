# Localized resources for helper module AzureDevOpsDsc.Common.

ConvertFrom-StringData @'

    MandatoryIsValidSwitchNotUsed = The '-IsValid' switch must be used when calling '{0}'. (AZDEVOPSCOMMON0501)
    MandatoryIsCompleteAndIsSuccessfulSwitchesNotUsed = Either the '-IsComplete' switch or the '-IsSuccessful' switch must be used when calling '{0}'. (AZDEVOPSCOMMON0502)
    MandatoryIsCompleteAndIsSuccessfulSwitchesBothUsed = Only one of the '-IsComplete' switch and the '-IsSuccessful' switch can be used when calling '{0}'. (AZDEVOPSCOMMON0503)
    MandatoryIsPresentAndIsAbsentSwitchesNotUsed = Either the '-IsPresent' switch or the '-IsAbsent' switch must be used when calling '{0}'. (AZDEVOPSCOMMON0504)
    MandatoryIsPresentAndIsAbsentSwitchesBothUsed = Only one of the '-IsPresent' switch and the '-IsAbsent' switch can be used when calling '{0}'. (AZDEVOPSCOMMON0505)

    AzDevOpsApiResourceAccessDenied = The Azure DevOps API returned an "ACCESS DENIED" error when performing an operation/request (using ResourceName of '{0}' and ResourceId of '{1}'). (AZDEVOPSCOMMON0601)
    AzDevOpsApiResourceWaitTimeoutExceeded = The '{0}' function (using ResourceName of '{1}' and ResourceId of '{2}') exceeded specified, maximum timeout ({3} milliseconds). (AZDEVOPSCOMMON0602)

    AzDevOpsOperationWaitTimeoutExceeded = The '{0}' function (using OperationId of '{1}') exceeded specified, maximum timeout ({2} milliseconds). (AZDEVOPSCOMMON0702)

    AzDevOpsApiRestMethodException = The '{0}' function returned an error when trying to send a HTTP request to the Azure DevOps API (after {1} unsuccessful, retry attempts): "{2}". (AZDEVOPSCOMMON0802)

'@
