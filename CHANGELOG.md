# Change log for AzureDevOpsDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- AzureDevOpsDsc
  - Azure Managed Identity supporting classes. These classes are used by `AzureDevOpsDsc.Common`.
  - Updated pipeline files to support change of default branch to main.
  - Added GitHub issue templates and pull request template
  ([issue #1](https://github.com/dsccommunity/AzureDevOpsDsc/issues/1))
  - Added the `AzDevOpsProject`, DSC Resource
  - Fixed non-terminating, integration tests ([issue #18](https://github.com/dsccommunity/AzureDevOpsDsc/issues/18))
  - Increased Azure DevOps, API timeout to 5 minutes to allow for busy/slow API
    operations ([issue #25](https://github.com/dsccommunity/AzureDevOpsDsc/issues/25)).
  - Updated contextual help ([issue #5](https://github.com/dsccommunity/AzureDevOpsDsc/issues/5)).
  - Removed `Classes` directory from being output in packaged module ([issue #10](https://github.com/dsccommunity/AzureDevOpsDsc/issues/10)).
  - Removed `Examples` directory from being output in packaged module ([issue #11](https://github.com/dsccommunity/AzureDevOpsDsc/issues/11)).
  - Moved 'Ensure' and 'RequiredAction' enums into 'Enum' directory and out of
    'prefix.ps1' ([issue #12](https://github.com/dsccommunity/AzureDevOpsDsc/issues/12)).
  - Added pipeline support for publish markdown content to the GitHub repository
    wiki ([issue #15](https://github.com/dsccommunity/AzureDevOpsDsc/issues/15)).
    This will publish the markdown documentation that is generated bu the
    build pipeline.
  - Added new source folder `WikiSource`. Every markdown file in the folder
    `WikiSource` will be published to the GitHub repository wiki. The markdown
    file `Home.md` will be updated with the correct module version on each
    publish to gallery (including preview).
- AzureDevOpsDsc.Common
  - Managed Identity has been added to the system. This feature can be used before invoking Invoke-DSCResource. With New-AzManagedIdentity, the bearer token is automatically authenticated, retrieved, and managed. It’s worth noting that bearer tokens take precedence over basic tokens. When using Invoke-AzDevOpsApiRestMethod, the token is automatically interpolated as required.
  - Added 'wrapper' functionality around the [Azure DevOps REST API](https://docs.microsoft.com/en-us/rest/api/azure/devops/)
  - Added Supporting Functions for Azure Managed Identity.

### Changed

- AzureDevOpsDsc
  - Enabled integration tests against https://dev.azure.com/azuredevopsdsc/ (see
    comment https://github.com/dsccommunity/AzureDevOpsDsc/issues/9#issuecomment-766375424
    for more information).
  - Updated pipeline file `RequiredModules.ps1` to latest pipeline pattern.
  - Updated pipeline file `build.yaml` to latest pipeline pattern.
- AzDevOpsProject
  - Added a validate set to the parameter `SourceControlType` to (for now)
    limit the parameter to the values `Git` and `Tfvc`.
  - Update comment-based help to remove text which the valid values are
    since that is now add automatically to the documentation (conceptual
    help and wiki documentation).

### Fixed

- AzDevOpsProject
  - Added description to the comment-based help.
