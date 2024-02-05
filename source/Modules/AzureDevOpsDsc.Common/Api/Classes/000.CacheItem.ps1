class CacheItem {
    [string] $Key
    [object] $Value
    [datetime] $created

    CacheItem([string] $Key, [object] $Value) {

        # The Key Can't be empty
        if (-not $Key) {
            throw "Key cannot be null or empty."
        }

        $this.Key = $Key
        $this.Value = $Value
        $this.created = Get-Date
    }

}
