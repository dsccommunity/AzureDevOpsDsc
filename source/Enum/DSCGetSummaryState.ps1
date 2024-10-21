<#
.SYNOPSIS
    Enumeration for DSC Get Summary State.

.DESCRIPTION
    This enumeration defines the possible states for DSC (Desired State Configuration) summary results.

.MEMBERS
    Changed
        Indicates that the state has changed.
    Unchanged
        Indicates that the state is unchanged.
    NotFound
        Indicates that the state was not found.
    Renamed
        Indicates that the state has been renamed.
    Missing
        Indicates that the state is missing.
#>
enum DSCGetSummaryState
{
    # Changed
    Changed = 0
    # Unchanged
    Unchanged = 1
    # Not Found
    NotFound = 2
    # Renamed
    Renamed = 3
    # Missing
    Missing = 4
}
