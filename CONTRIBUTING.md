# Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

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

The layout of the module is designed to:

* Rely on the consistency of the Azure DevOps REST API
* Clearly scope and separate, distinct functionality and components
* Allow heavy re-use of generic, Azure DevOps REST API wrapper functionality
* Minimise the complexity of the DSC Resources themselves, in turn, aiming to:
  * Reduce the amount of new functionality and effort required to add new, DSC Resources
  * Increase the reliability and robustness of the DSC Resources

## Running the Tests

If want to know how to run this module's tests you can look at the [Testing Guidelines](https://dsccommunity.org/guidelines/testing-guidelines/#running-tests)
