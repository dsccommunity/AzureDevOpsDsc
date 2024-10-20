Function Format-DescriptorType {

    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory)]
        [System.String]$DescriptorType
    )

    # Switch on the DescriptorType
    switch ($DescriptorType) {

        # The Descriptor Name in the API is different to the Descriptor Name in the DSC Resource.
        "GitRepositories" {
            return "Git Repositories"
        }

        # All other else, keep the same descriptor type
        default {
            return $DescriptorType
        }
    }

}
