# Testing Demo Applications <!-- omit in toc -->

There are 4 microservices deployed in the cluster by the [setup.sh](../script/setup.sh) script. Three of them expose a few REST APIs and another one exposes SOAP APIs.

Those services that expose REST APIs come with Swagger UI which you can use to test the APIs in each service. However, you can also use Postman to both of REST APIs and SOAP APIs as well.

## Requirements <!-- omit in toc -->

- [Postman](https://www.postman.com/downloads/)

## Table of Contents <!-- omit in toc -->

- [Testing REST APIs via Swagger UI](#testing-rest-apis-via-swagger-ui)
- [Testing REST and SOAP APIs with Postman](#testing-rest-and-soap-apis-with-postman)
  - [Import Postman Collections and Environments](#import-postman-collections-and-environments)
  - [Testing APIs exposed through services directly](#testing-apis-exposed-through-services-directly)
  - [Testing APIs exposed through API gateway](#testing-apis-exposed-through-api-gateway)

## Testing REST APIs via Swagger UI

1. Open a route for the service that you need to test.

   ![testing service](../images/testing-service-1.png)

2. Append `/swagger-ui` at the end of URL then press `Enter`. You should be able to see Swagger UI page that shows all REST API endpoints exposed by the service.

   ![testing service](../images/testing-service-2.png)

3. Click on the endpoint you need to test, the panel will expand. Then click on **Try it out** button.

   ![testing service](../images/testing-service-3.png)

4. Enter paramenter(s) (if necessary), then click **Execute** button. The request URL and response will be shown up like a screenshot below.

   ![testing service](../images/testing-service-4.png)

## Testing REST and SOAP APIs with Postman

### Import Postman Collections and Environments

1. Create a new workspace.

   ![import postman collection](../images/testing-service-5.png)

   ![import postman collection](../images/testing-service-6.png)

2. Import this [Postman collection](../postman/demo-application-testing.postman_collection.json).

   ![import postman collection](../images/testing-service-7.png)

   ![import postman collection](../images/testing-service-8.png)

   ![import postman collection](../images/testing-service-9.png)

   ![import postman collection](../images/testing-service-10.png)

3. Import this [Postman Environments](../postman/default.postman_environment.json).

   ![import postman environment](../images/testing-service-11.png)

   ![import postman environment](../images/testing-service-12.png)

   ![import postman environment](../images/testing-service-13.png)

4. Edit Postman `cluster-domain` environment variable by replacing the OpenShift cluster domain.

   ![import postman environment](../images/testing-service-14.png)

   ![import postman environment](../images/testing-service-15.png)

### Testing APIs exposed through services directly

Switch back to **Collection** panel, then open the request you need to test.

   ![import postman environment](../images/testing-service-16.png)

### Testing APIs exposed through API gateway

1. Import this [Postman collection](../postman/3scale-api-testing.postman_collection.json) to the workspace.

2.