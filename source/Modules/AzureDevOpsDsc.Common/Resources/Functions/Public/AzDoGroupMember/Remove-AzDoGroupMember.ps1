Function New-AzDoGroupMember {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (

        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Members')]
        [System.String]$GroupMembers=@(),

        [Parameter()]
        [Alias('Lookup')]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    $return

}
