<#
    .SYNOPSIS
        Defines the `RequiredAction` of the DSC resource.
#>
enum RequiredAction
{
    None
    Get
    New
    Set
    Remove
    Test
    Error
}
