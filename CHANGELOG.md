# Change log for AzureDevOpsDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- AzureDevOpsDsc
  - Updated pipeline files to support change of default branch to main.
  - Added GitHub issue templates and pull request template
  ([issue #1](https://github.com/dsccommunity/AzureDevOpsDsc/issues/1))
  - Added the `AzDevOpsProject`, DSC Resource
  - Fixed non-terminating, integration tests ([issue #18](https://github.com/dsccommunity/AzureDevOpsDsc/issues/18))
- AzureDevOpsDsc.Common
  - Added 'wrapper' functionality around the [Azure DevOps REST API](https://docs.microsoft.com/en-us/rest/api/azure/devops/)

### Fixed

- Test PR, should not be merged.
