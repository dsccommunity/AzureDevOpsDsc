Function ConvertTo-ACL
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[HashTable[]]$Permissions,

		[Parameter(Mandatory)]
		[string]$SecurityNamespace,

		[Parameter(Mandatory)]
		[bool]$isInherited
	)

	Write-Verbose "[ConvertTo-ACL] Started."

	$ACLs = [System.Collections.Generic.List[HashTable]]::new()

	ForEach($Permission in $Permissions) {

		$params = @{
			SecurityNamespace = $SecurityNamespace
			Identity = $Permission.Identity
		}

		#
		# Convert the Permission to an ACL Token
		$ACL = @{
			inherited = $isInherited
			token = ConvertTo-ACLToken @params
			aces = @{}
		}


	}



}
