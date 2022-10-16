# Red Hat 3Scale API Management on OpenShift Demo

Red Hat 3Scale API Management on OpenShift Container Platform demonstration preparation and guide.

## Table of Contents

- [Installation Guide](/documents/installation.md)
- [3Scale Architecture](#3scale-architecture)
  - [3Scale high level overview](#3scale-high-level-overview)
  - [3Scale basic architecture](#3scale-basic-architecture)
  - [3Scale basic resources](#3scale-basic-resources)
- [Demo Cluster Overview](#demo-cluster-overview)
- [Demo Applications](#demo-applications)
- [Testing Demo Applications](#testing-demo-applications)
- [Working With 3Scale API Management](#working-with-3scale-api-management)
- [Multi-Environments Management Guideline](#multi-environments-management-guideline)

## 3Scale Architecture

### 3Scale high level overview

![3scale overview](images/3scale-overview.png)

### 3Scale basic architecture

![3scale architecture](images/3scale-architecture.png)

### 3Scale basic resources

- **Backend** - represents a deployed backend application or service by pointing to its root URL.

- **Product** - previously called services, represent a collection of 3scale objects that pertain to a specific client or group of users. Products contain the following 3scale configuration objects:

  - **Application plans** - sets of access rights that allow users to define different rules for consumers of managed APIs. You can use application plans to set rate limits, enable features, resources, and methods for API users.

  - **Applications** - represent a client application who is consuming API(s) via API gateway.

  - A map of backends to applications

  Note that backends do not belong to a product. This is because the same backend can be associated with several different products. Different products do not need separate backends for the same underlying API.

![3scale resources](images/3scale-resources.png)

## Demo Cluster Overview

Once you've done all [installation steps](/documents/installation.md) above, the overview of OpenShift cluster will be like this.

## Demo Applications

The applictions used for demo are forked from projects created by the clever people out there. All credits are given to the project owners.

- [Sample Quarkus Microservices](https://github.com/audomsak/sample-quarkus-microservices)

- [Sample SOAP Spring Boot microservice](https://github.com/audomsak/ws-employee-soapcxf)

## Testing Demo Applications

Follow this [guide](documents/testing-application.md) for how to test the demo applications.

## Working With 3Scale API Management

1. [Onboarding new API consumer](documents/onboarding-new-api-consumer.md)
2. [Expose SOAP API through API Gateway](documents/expose-soap-api.md)
3. [Secure API with API Key-pair](documents/secure-with-api-key-pair.md)
4. Limit API call with Rate Limit feature
5. Secure API with OAuth2 using Red Hat SSO
6. Self-managed (Off-cluster) API Gateway

## Multi-Environments Management Guideline

TODO
