class DscResourceReason
{
    [DscProperty()]
    [string] $Code

    [DscProperty()]
    [string] $Phrase

    DscResourceReason([hashtable]$ht)
    {
        $this.Code = $ht.Code
        $this.Phrase = $ht.Phrase
    }

}
