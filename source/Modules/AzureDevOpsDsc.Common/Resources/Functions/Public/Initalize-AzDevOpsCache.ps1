
function Initialize-Cache {



    # Attempt to load the cache from the file
    Import-CacheObject -CacheType 'Project'
    Import-CacheObject -CacheType 'Team'

    #


}
