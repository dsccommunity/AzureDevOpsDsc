
class AzdoTokenIdentifier
{
    # Function to get the type of the token
    hidden [HashTable]FormatRegex([String]$type)
    {
        $hashtable = @{
            type = $type
        }

        # Get all Capture Groups and add them into a hashtable
        $matches.keys | Where-Object { $_.Length -gt 1 } | ForEach-Object {
            $hashtable."$_" = $matches."$_"
        }

        return $hashtable

    }

    #
    # Function to get the type of the token
    [HashTable]GetType([string]$token, $LocalizedDataAzTokenPatten)
    {
        foreach ($tokenPatten in $LocalizedDataAzTokenPatten.keys)
        {
            $pattern = $LocalizedDataAzTokenPatten."$tokenPatten"
            if ($token -match $pattern)
            {
                return  $this.FormatRegex($tokenPatten)
            }
        }

        return $null
    }
}
