
Function Test-AzDoGroupMember {

    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,

        [Parameter()]
        [string]
        $GroupDescription=$null,

        [Parameter()]
        [Alias('Name')]
        [hashtable]$GetResult

    )


}
