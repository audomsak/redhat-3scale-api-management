# Secure Your API With OpenID Connect OAuth 2.0 Standard <!-- omit in toc -->

## Securing APIs with Red Hat Single Sign-on and OAuth <!-- omit in toc -->

### Describing OIDC Authentication Workflow in Red Hat 3scale API Management

You can configure 3scale API Management to require OpenID Connect (OIDC) as an authentication mechanism for your APIs. This means that 3scale API Management verifies the following:

- Each request contains a JSON Web Token (JWT).

- The JWT token is cryptographically signed by the configured OIDC provider.

- The JWT token is valid, for example not expired.

- The JWT token contains the necessary claims, such as the authorized party (azp) or audience (aud).

When you configure OIDC integration, APIcast reads the configuration of the OIDC provider by using the `https://OIDC_PROVIDER_HOST/.well-known/openid-configuration` discovery endpoint. APIcast caches information required for validating JWT tokens, such as public keys and signing algorithms.

Requests to the protected API then require a valid JWT token. The following diagram provides an example of an authentication request flow:

![sso config](../images/oauth-auth-flow.png)

### Integrating 3scale API Management with Red Hat Single Sign On (RHSSO) <!-- omit in toc -->

When you configure OIDC integration in your product, 3scale API Management requires that the authorized party (azp) claim in the JWT token corresponds to the API credentials that you associate with an application in your product. However, RHSSO issues JWT tokens. Consequently, 3scale API Management must synchronize application credentials with RHSSO.

The Zync component is responsible for the credential synchronization with RHSSO. When you create a new application, the Sidekiq component schedules Zync to synchronize the data with RHSSO. Zync asynchronously communicates with RHSSO and creates the API credentials.

![sso config](../images/oauth-acc-flow.png)

## Steps <!-- omit in toc -->

- [1. Configure SSO](#1-configure-sso)
- [2. Setting Authentication mode for API Product](#2-setting-authentication-mode-for-api-product)
- [3. Recreate Application](#3-recreate-application)
- [4. Testing](#4-testing)

## 1. Configure SSO

You have to setup Zync client in SSO (Keycloak) so 3scale can integrate with SSO and call SSO APIs.

1. Login to Red Hat SSO web console using the URL and credential from step 4 above.

2. Click **Clients** menu from left panel.

    ![sso config](../images/sso-config-1.png)

3. Click **Create** button.

    ![sso config](../images/sso-config-2.png)

4. Click **Select file** button. Browse to [zync-client.json](../manifest/sso/zync-client.json) file.

    ![sso config](../images/sso-config-3.png)

5. Click **Save** button.

    ![sso config](../images/sso-config-4.png)

6. Go to **Service Account Roles** tab. In the **Client Roles** section, select **Realm Management**. Click **manage clients**, then click **Add selected** button.

    ![sso config](../images/sso-config-5.png)

7. Go to **Credentials** tab. Look for **Secret** value, you will need this when setting up OAuth authentication in 3scale so keep this page open in web browser.

    ![sso config](../images/sso-config-6.png)

## 2. Setting Authentication mode for API Product

1. From main dashboard, click **Human Resource Services** link to open Product dashboard page.

   ![oauth secure](../images/oauth-1.png)

2. Enter following details:
   - **AUTHENTICATION** section
      - Select **OpenID Connect Use OpenID Connect for any OAuth 2.0 flow.** option.

   - **OPENID CONNECT (OIDC) BASICS** section

        - **OpenID Connect Issuer Type:** `Red Hat Single Sign-On`
        - **OpenID Connect Issuer:** Enter a URL in this format: `https://zync-client:<SECRET>@keycloak-sso.apps.<CLUSTER DOMAIN>/auth/realms/example`

            - **SECRET:** **Zync-client** client secret get from **Step 7** in [Configure SSO](#1-configure-sso) step above.
            - **CLUSTER DOMAIN:** OpenShift cluster domain. (You can also run `oc whoami --show-console|awk -F'apps.' '{print $2}'` command in terminal to get cluster domain value)

            For example, `https://zync-client:2IaLsOOTEZzTOBeTp5U8OfIeQiKYmNtI@keycloak-sso.apps.cluster-hrpdc.hrpdc.sandbox140.opentlc.com/auth/realms/example`

   - **OIDC AUTHORIZATION FLOW** section

        - Check **Authorization Code Flow** and **Service Accounts Flow** options.

   ![oauth secure](../images/oauth-2.png)

3. Scroll down to bottom of the page then click **Update Product** button.

   ![oauth secure](../images/oauth-3.png)

## 3. Recreate Application

Due to the authentication mode for API product has been changed to OpenID Connect OAuth 2.0 flow, so the existing applications (**Test Corp HR Mobile** app, in this case) can't call APIs using API Key or API Key-Pair anymore. So, we need to recreate the application which 3scale will generate a new client ID in SSO for the application to be used for authentication in OAuth flow.

1. Select **Applications -> Listing** menu from left panel. Then click **Test Corp HR Mobile** link to open application page.

   ![oauth secure](../images/oauth-4.png)

2. Click **Edit** link.

   ![oauth secure](../images/oauth-5.png)

3. Click **Delete** then **OK** button to confirm deletion.

   ![oauth secure](../images/oauth-6.png)

4. You'll be directed to the Application dashboard. Click **Create application** button.
5. ![oauth secure](../images/oauth-7.png)

6. Enter following details then click **Create application** button.

   - **Account:** `Test Corp`
   - **Product:** `Human Resource Services`
   - **Application plan:** `Free`
   - **Name:** `Test Corp HR Mobile`
   - **Description:** `Test Corp HR Mobile Application`

   ![oauth secure](../images/oauth-8.png)

7. A new application should be created with assigned Application Plan as well as an auto genereated Client ID and Client Secret. This will be used for authentication when calling APIs.

   ![oauth secure](../images/oauth-9.png)

8. Go to SSO web console, Select **Clients** menu from left panel. You'll see a new client with the same Client ID in 3scale gets created automatically. This is done by Zync client component. Click on the client ID, you'll see the details.

   ![oauth secure](../images/oauth-10.png)

   ![oauth secure](../images/oauth-12.png)

9. Promote Configuration changes to Staging and Production.

   ![oauth secure](../images/oauth-11.png)

## 4. Testing

1. Update `client-id` and `client-secret` variable in Postman Environments with **Client ID** and **Client Secret** generated when you recreate the application (see step 7 in [Recreate Application](#3-recreate-application)) and click **Save** button.

   ![oauth secure](../images/oauth-13.png)

2. [Test the API secured with OAuth](testing-application.md#testing-api-secured-with-oauth) using [3Scale API Testing (OAuth)](../postman/3scale-api-testing-oauth.postman_collection.json) collection.

---
