<#
.SYNOPSIS
Represents a cache item with a key, value, and creation timestamp.

.DESCRIPTION
The CacheItem class is used to store a key-value pair along with the timestamp when the item was created.
It ensures that the key is not null or empty upon instantiation.

.PARAMETER Key
The key associated with the cache item. It must be a non-empty string.

.PARAMETER Value
The value associated with the cache item. It can be any object.

.PARAMETER created
The timestamp when the cache item was created. It is automatically set to the current date and time upon instantiation.

.CONSTRUCTOR
CacheItem([string] $Key, [object] $Value)
Creates a new instance of the CacheItem class with the specified key and value.
Throws an exception if the key is null or empty.

.EXAMPLE
$cacheItem = [CacheItem]::new("exampleKey", "exampleValue")
Creates a new CacheItem instance with the key "exampleKey" and the value "exampleValue".

.NOTES
Author: Michael Zanatta
#>

class CacheItem
{
    [string] $Key
    [object] $Value
    [datetime] $created

    CacheItem([string] $Key, [object] $Value)
    {
        # The Key Can't be empty
        if (-not $Key)
        {
            throw "Key cannot be null or empty."
        }

        $this.Key = $Key
        $this.Value = $Value
        $this.created = Get-Date
    }

}
