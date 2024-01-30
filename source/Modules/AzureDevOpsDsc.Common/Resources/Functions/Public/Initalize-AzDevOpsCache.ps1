
function Initialize-Cache {
    # Create an empty hashtable
    $Global:AZDOCache = @{}

    # You can pre-populate the cache with some default values if necessary
    # $cache["key1"] = "value1"
    # $cache["key2"] = "value2"
    # ...

    # Return the hashtable (cache)
    return $cache
}

# Usage:
$myCache = Initialize-Cache

# Display the initialized cache (it will be empty unless you've added default values)
$myCache
