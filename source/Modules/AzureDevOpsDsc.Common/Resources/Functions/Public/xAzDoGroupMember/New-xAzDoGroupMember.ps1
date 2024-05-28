Function New-xAzDoGroupMember {

    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject[]])]
    param
    (
        [Parameter(Mandatory)]
        [Alias('Name')]
        [System.String]$GroupName,

        [Parameter()]
        [Alias('Members')]
        [System.String[]]$GroupMembers=@(),

        [Parameter()]
        [HashTable]$LookupResult,

        [Parameter()]
        [Ensure]$Ensure,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force

    )

    #
    # Fetch the group members and perform a lookup of the members



    ForEach ($GroupMember in $GroupMembers) {

        # Perform a case-insensitive lookup against the cached group members

        $GroupMember = $GroupMember.ToLower()

        If ($LookupResult.ContainsKey($GroupMember)) {

            $LookupResult[$GroupMember] = $true

        }

        # Update the livecache with the new group member

    }



    "TRIGGED" | Out-File "C:\Temp\New-xAzDoGroupMember.txt"


    return

}
