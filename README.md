
# HelloID-Conn-Prov-Target-OutSystems-RoleManagement

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements. |

<p align="center">
  <img src="https://www.tools4ever.nl/connector-logos/outsystems-logo.png" width="500">
</p>

## Table of contents

- [HelloID-Conn-Prov-Target-OutSystems-RoleManagement](#helloid-conn-prov-target-outsystems-rolemanagement)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
    - [Endpoints](#endpoints)
    - [Available lifcecyle events](#available-lifcecyle-events)
  - [Getting started](#getting-started)
    - [Connection settings](#connection-settings)
    - [Remarks](#remarks)
      - [A __fixed__ base URI but multiple environments](#a-fixed-base-uri-but-multiple-environments)
      - [Correlation only](#correlation-only)
      - [No verification if the user exists](#no-verification-if-the-user-exists)
        - [If the group cannot be found](#if-the-group-cannot-be-found)
      - [Error handling](#error-handling)
  - [Getting help](#getting-help)
  - [HelloID docs](#helloid-docs)

## Introduction

_HelloID-Conn-Prov-Target-OutSystems-RoleManagement_ is a _target_ connector. OutSystems is a low-code development platform that enables organizations to build and deploy web and mobile applications faster and with less manual coding. It provides a visual development environment where developers can create applications by dragging and dropping pre-built components and logic, rather than writing code from scratch.

With OutSystems, developers can rapidly build enterprise-grade applications using a visual interface, leveraging built-in features and functionalities. It simplifies the application development process, allowing developers to focus on business logic and user experience rather than dealing with the complexities of traditional coding. OutSystems provides a set of REST API's that allow you to programmatically interact with its data.

| :information_source: Information |
|:---------------------------|
| This connector only manages entitlements. |

### Endpoints

| Endpoint | Description |
|------------|-----------|
| portalusers | Grant/revoke group memberships |
| groups | Lists all available groups |

### Available lifcecyle events

| Event  | Description | Notes |
|------------|-----------|-------------|
| create.ps1 | Correlates the Account | - |
| permissions.ps1 | Retrieves the permissions from OutSystems | - |
| grant.ps1 | Grants a permission to a person | - |
| revoke.ps1 | Revokes a permission from a person | - |

## Getting started

### Connection settings

The following settings are required to connect to the API.

|Setting|Description|Mandatory|Notes|
|------------|-----------|------------|-----------|
|UserName|The UserName to connect to the API|Yes|
|Password|The Password to connect to the API|Yes|
|API|The name API that will be used<br>Example: `Customeruseranagement_API`|Yes| Can be obtained from the full URL to the API.<br> https://customer-test.outsystemsenterprise.com/CustomerUsermanagement_API/rest/usermanagement/portalusers
| Environments | A comma separated list of environments | Yes | -
| BaseUrl | The URL to OutSystems. This does not need to be changed | No | For more information, please refer to: [A __fixed__ base URI but multiple environments](#a-fixed-base-uri-but-multiple-environments)

### Remarks

#### A __fixed__ base URI but multiple environments

This connector is designed for customers who have multiple instances of an OutSystems environment. We made the assumption that:

- Each OutSystems environment will be serviced at: `https://{environment}.outsystemsenterprise.com`.

- For both the `revoke` and `grant` lifecycle actions, `{environment}` will be replaced with the _environment_ from `$pRef.Environment`.<br>The PowerShell code is as follows:

```powershell
$baseUrl = ($($config.BaseUrl)).Replace("{environment}", $($pRef.Environment)

# The 'baseUrl' is the URL to the OutSystems environment  'https://{environment}.outsystemsenterprise.com'.
# {environment} will be replaced with the value of the 'reference.environment'.
```

- The `permissions.ps1` script uses the comma separated list of environments defined in the _configuration_ to retrieve and build a list of permissions.

#### Correlation only

Because both a `GET` and a `POST` call to retrieve/create persons is not available, the correlation process merely creates an `AccountReference` containing the following fields:

| Property        | Description                                               | Current Value                                              |
|-----------------|-----------------------------------------------------------|------------------------------------------------------------|
| UserName    | The EmailAddress of the user.<br>This is the value of the `UserName` property for both the `grant` & `revoke` lifecyle actions. | In version _1.0.0_ of the connector, this is mapped to: `$p.Accounts.MicrosoftActiveDirectory.mail`|

> A person might have an account on each OutSystems environment. However, the _userName_ is always the _EmailAddress_. Therefore, the correlate lifecycle action only sets the `AccountReference` containing the persons _EmailAddress_. The reference to the correct systems comes from the permission. `$pRef.Environment`

#### No verification if the user exists

There is no explicit check to verify if the _username_ (which is the email address) exists in OutSystems. However, a validation is performed on the __domain__ portion of the email address. This means that as long as the domain portion is correct, the membership can be granted to any person, regardless of whether that specific _username_ exists in the OutSystems.

##### If the group cannot be found

- `Grant`<br>
If the group cannot be found during a `grant` lifecycle action, OutSystems will return a ___500: Internal Server error___ with a message indicating the group does not exist.

- `Revoke`<br>
OutSystems will always return a _200: OK_ even if the group cannot be found during a `revoke` lifecycle action.

#### Error handling

OutSystems consistently returns a ___500: Internal Server error___ in response to various errors. That can make it challenging to determine whether the data sent is the cause of the error or, if there are other underlying issues on the OutSystems platform. Both the _verbose_ and _auditlog_ messages will show the error details that come back from OutSystems.

## Getting help

> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/hc/en-us/articles/360012558020-Configure-a-custom-PowerShell-target-system) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID docs

The official HelloID documentation can be found at: https://docs.helloid.com/
