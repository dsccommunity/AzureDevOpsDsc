Function Set-xAzDoGroupMember {

    param(

        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Members')]
        [System.String[]]$GroupMembers=@(),

        [Parameter()]
        [Alias('Lookup')]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force

    )

    #
    # Add

    $LookupResult | Export-Clixml C:\Temp\test.xml

    "TRIGGERED" | Out-File "C:\Temp\Set-xAzDoGroupMember.txt"

    $return

}
