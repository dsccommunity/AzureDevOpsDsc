Function Set-xAzDoOrganizationGroup {

    param(

        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('DisplayName')]
        [System.String]$GroupDisplayName,

        [Parameter()]
        [Alias('Description')]
        [System.String]$GroupDescription,

        [Parameter()]
        [Alias('Lookup')]
        [System.String]$LookupResult,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force

    )

    #
    # Depending on the type of lookup status, the group has been renamed the group has been deleted and recreated.

    if ($LookupResult.Status -eq [DSCGetSummaryState]::Renamed) {

        # For the time being write a warning and return
        Write-Warning "[Set-xAzDoOrganizationGroup] The group has been renamed. The group will not be set."
        return

    }

    #
    # Update the group

    $params = @{
        ApiUri = "https://dev.azure.com/{0}" -f $Global:DSCAZDO_OrganizationName
        GroupName = $GroupName
        GroupDisplayName = $GroupDisplayName
        GroupDescription = $GroupDescription
        GroupDescriptor = $LookupResult.descriptor
    }

    # Set the group from the API
    $group = Set-DevOpsGroup @params

    #
    # Return the group from the cache

    return $group.Value

}
