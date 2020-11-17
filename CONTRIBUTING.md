# Contributing

## Getting Started

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

---

## Understanding the Module

The `AzureDevOpsDsc` module consists of a few key components:

* The Desired State Configuration (DSC) resources (to be used within DSC configurations).

* The nested, `AzureDevOpsDsc.Common` module, which itself, consists of the following
  sets of functions/commands:

  * `Api` - These are used as generic wrappers around the
    Azure DevOps REST API), aimed to minimise duplication of functionality and
    code across all `Resources`.

  * `Connection` - These support connection to the Azure DevOps REST API.

  * `Resources` - These invoke the `Api` functions/commands to
      manage specific, Azure DevOps REST API resources (e.g. `Projects`).

  * `Server` - These are specific to Azure DevOps
    **Server** - the self-hosted, typically on-premise, edition of Azure DevOps.

  * `Services` - These are specific to Azure DevOps
    **Services** - the Microsoft, cloud-hosted, 'Software-as-a-Service' (SaaS)
    solution.

The layout/structure of the module and it's resources/components is designed to:

* Rely on the consistency and structure of the Azure DevOps REST API
* Clearly scope and separate, distinct functionality and components
* Allow heavy re-use of generic, Azure DevOps REST API wrapper functionality
* Minimise the complexity of the DSC Resources themselves, in turn, aiming to:
  * Reduce the amount of new functionality and effort required to add new, DSC Resources
  * Increase the reliability and robustness of the DSC Resources
* Allow all the DSC Resources to be able to use independent, Personal Access Tokens
  (PATs) to allow distinct PATs, with distinct privileges, to perform distinct
  operations (as opposed to requiring a single PAT with excess privileges).

---

## Running the Tests

If want to know how to run this module's tests you can look at the [Testing Guidelines](https://dsccommunity.org/guidelines/testing-guidelines/#running-tests)

### Setup of **Remote**, Integration Tests

The Integration tests for this module, run as part of this build, require a
disposable instance of Azure DevOps Services that can be used for creating,
updating and deleting `Projects`, `Teams` and other resources within Azure DevOps.

>**IMPORTANT**: The build pipeline itself can run in a non-disposable Azure
>DevOps organization/collection, but ensure you **DO NOT** setup the following
>variables to point at that non-disposable organization/collection. Doing this
>could result in **loss of code/data/service** because the Integration Tests are
>creating and dropping resources within the organization/collection.

Two variables will need setting up in your Azure DevOps, pipeline:

* **`AzureDevOps.Integration.ApiUri`** - Which needs to contain the URI of your disposable,
AzureDevOps, organization API. For example, `https://dev.azure.com/yourDisposableOrganizationNameHere/_apis/`

* **`AzureDevOps.Integration.Pat`** - Which needs to contain the Personal Access
Token (PAT) to be used to connect to the disposable, Azure DevOps instance.

>**IMPORTANT**: Do not use a live/production/working, Azure DevOps Services/Server
>organization/collection in these variables - **This will likely result in data loss.**

### Setup of **Local**, Integration Tests

If you want to run the Integration Tests locally (i.e. on a workstation used for
development), the following actions need to be performed:

* Access/Use of the Local Configuration Manager (LCM) on the local workstation
  requires Administrator permissions on the workstation. As a result, the session/
  tool executing the Integration tests must be running with Administrator
  privileges. Failure to do this will result in an error when the tests are
  initiated.

* You need to set the following environment variables so the build will determine
  it needs to execute the Integration tests, and it has the Personal Access Token
  (PAT) and API URI

  ```Powershell
    $env:CI = $true
    $env:AZUREDEVOPSINTEGRATIONAPIURI = 'YourApiUriHere'
    $env:AZUREDEVOPSINTEGRATIONPAT = 'YourPatHere'
  ```

>**Important**: It is not recommended to store any Personal Access Token (PAT)
>in plain text within a text file or script. Ensure no PAT token is added to
source control commmits as part of changes made. These PATs would likely be
available within the public, commit history and could/would pose a security risk
to your Azure DevOps instance.
