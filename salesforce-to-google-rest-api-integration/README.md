Hello there! 👋
I would like to present a complete guide for Salesforce to Google REST API Integration.
Below you can find the step-by-step configuration.
No more talk. Let's begin!

## Architecture

<img src="https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/dkX3FXbRTHTk.png" alt="salesforce to google rest api integration" />

## Custom App
**Google**

*create a project, enable API, configure OAuth consent screen and set scopes, create credentials.*

1. Go to [Manage resources](https://console.cloud.google.com/cloud-resource-manager),
 1. Sign in with Google Account.
 2. Create a new project. - `CREATE PROJECT` button.
2. Go to [API Library](https://console.cloud.google.com/apis/library).
 1. Make sure that previously created project is selected (picklist next to the Google Cloud logo).
 2. Click the needed API card.
 3. **IMPORTANT!** Click `TRY THIS API`. It redirects you to complete documentation about the selected endpoint. Here you can find **HTTP Method**, **HTTP URL** and required **OAuth 2.0 Scopes**. Keep this page for the future use.
 4. When you are fine with all permissions enable API by hitting the `ENABLE` button on the previous page.
3. Go to [OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent).
 1. Execute all steps.
 2. Add all needed scopes for the selected Endpoint. Get scopes from step 2.3. **Note!** Be careful, add only necessary access! Scope defines what type of access your app can guarantee.
4. If you added sensitive scopes, you need to go through the verification. You can do it with the `PREPARE FOR VERIFICATION` button. It's not necessary to accomplish our tutorial, let's skip it for now.
5. Go to [Credentials](https://console.cloud.google.com/apis/credentials).
 1. Hit `+ CREATE CREDENTIALS`. Choose `Create OAuth client ID`.
 2. Set  `Application type` as ` Web application`.
 3. Skip `URIs` configuration just for now.
6.  You should see `Client ID` and `Client Secret`. **Note!** Copy and save it for future use.

## Auth. Provider
**Salesforce**

*configure Auth. Provider, get callback URL*.

[Configure a Salesforce Authentication Provider](https://help.salesforce.com/s/articleView?id=sf.sso_provider_sfdc.htm&type=5)

1. `Setup` > `Auth. Providers` > `New`

Property | Description
-------- | -------
Provider Type | Google
Name | Auth. Provider Name e.g. Google
URL Prefix | Used in the client configuration URLs e.g. Google
Customer Key | Client ID from step Custom App#6
Customer Secret | Client Secret from step Custom App#6
Authorize Endpoint URL | Leave default https://accounts.google.com/o/oauth2/auth
Token Endpoint URL | Leave default https://accounts.google.com/o/oauth2/token
User Info Endpoint URL | Leave default https://www.googleapis.com/auth2/v3/userinfo
Default Scopes | `openId` + go to [API Library](https://console.cloud.google.com/apis/library) and check the documentation for your Google API. All available scopes you can find [here](https://developers.google.com/identity/protocols/oauth2/scopes)

2. Hit `Save`.
3. Copy the `Callback URL` from the `Salesforce Configuration` section.
4. Go to [Credentials](https://console.cloud.google.com/apis/credentials) and edit the previously added `OAuth 2.0 Client ID` (Step Custom App#5).
5. Add copied `Callback URL` to the `Authorised redirect URLs` section.

## Named Credentials
**Salesforce**

*configure Named Credentials with Auth. Provider*

### Legacy Named Credentials

[Creaate a Legacy Named Credentials](https://help.salesforce.com/s/articleView?id=sf.external_services_mulesoft_create_named_credential.htm&language=en_US&r=https%3A%2F%2Fwww.google.com%2F&type=5)

1. `Setup` > `Named Credentials` > Arrow next to `New` > `New Legacy`
2. Complete the configuration form

Property | Description
-------- | -------
Label | Named Credentials Label e.g Google
Name | Named Credentials Name e.g Google. It will be used in Apex
URL | It depends on your API. Go to [API Library](https://console.cloud.google.com/apis/library), and your API and check the documentation. Add base endpoint URL e.g [https://www.googleapis.com](https://www.googleapis.com/)
Identity Type | `Named Principal` *Use the same set of credentials for all users who access the external system from your org. Select this option if you designate one user account on the external system for all your Salesforce org users.* More details you can find [here](https://help.salesforce.com/s/articleView?id=sf.named_credentials_define.htm&type=5)
Authentication Protocol | OAuth 2.0
Authentication Provider | Provider created in the previous step.
Scope |  Optional. Specifies the scope of permissions to request for the access token. Your authentication provider determines the allowed values. The value that you enter replaces the Default Scopes value that’s defined in the specified authentication provider.

3. Save

### New Named Credentials

![Named Credentials and External Credentials](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/Pasted-image-20220918154808.png)

#### External Credenitials

[Create and Edit an External Credential](https://help.salesforce.com/s/articleView?id=sf.create_edit_external_credential.htm&type=5)

1. `Setup` > `Named Credentials`
2. Choose the `External Credentials` tab and click `New`.

Property | Description
-------- | -------
Label | External Credentials Label e.g Google
Name | External Credentials Name e.g Google.
Authentication Protocol | OAuth 2.0
Authentication Provider | Provider created in the previous step.
Scope | Optional. Specifies the scope of permissions to request for the access token. Your authentication provider determines the allowed values. The value that you enter replaces the Default Scopes value that’s defined in the specified authentication provider.

3. Save

#### Named Credentials

[Create and Edit a Named Credential](https://help.salesforce.com/s/articleView?id=sf.create_edit_named_credential.htm&type=5)

1. `Setup` > `Named Credentials`.
2. Choose the `Named Credentials` tab and click `New`.

Property | Description
-------- | -------
Label | Named Credentials Label e.g Google
Name | Named Credentials Name e.g Google. Will be used in Apex.
URL | It depends on your API. Go to [API Library](https://console.cloud.google.com/apis/library), and your API and check the documentation. Add base endpoint URL e.g [https://www.googleapis.com](https://www.googleapis.com/)
External Credentials | Choose the one created in the previous section.

#### Permission Set
1. `Setup` > `Permission Sets` > `New`

Property | Description
-------- | -------
Label | Permission Set Label e.g. Google API
Name | Permission Set API Name e.g. GoogleAPI

2. `Setup` > `Named Credentials` > `External Credentials`
3.  Click `New` next to `Permission Sets Mappings`.

Property | Description
-------- | -------
Permission Set | Select Permission Set created in the previous step.
Identity Type | Named Principal

4. Assign Permission Set to your integration user.
5. Go back `External Credentials` page. Click the arrow next to the `Permission Set Mappings` and hit `Authenticate`.

## Apex Code

**Salesforce**

1. Create an APEX class. e.g `GoogleWebService`.
2. Go to [API Library](https://console.cloud.google.com/apis/library). Choose your API and open documentation.
3. Choose a concrete endpoint. Check REST API `method` and `HTTP request` params.

Here you can find really simple code to make a callout.

```java
public with sharing class GoogleWebService {
    public static void makeCallout() {
        HttpRequest request = new HttpRequest();
        request.setMethod('REST API METHOD');
        //request.setMethod('GET');
        request.setEndpoint('callout:NAMED_CREDENTIALS_NAME/' + path);
        //request.setEndpoint('callout:NAMED_CREDENTIALS_NAME' + '/users/me/calendarList');

        Http http = new Http();
        HTTPResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
        }
    }
}
```

---

If you have some questions feel free to ask in the comment section below. :)

Was it helpful? Check out our other great posts [here](https://beyondthecloud.dev/blog).

---

## Resources
- [Create and Edit an External Credential](https://help.salesforce.com/s/articleView?id=sf.create_edit_external_credential.htm&type=5)
- [Create and Edit a Named Credentials](https://help.salesforce.com/s/articleView?id=sf.create_edit_named_credential.htm&type=5)
- [Configure a Salesforce Authentication Provider](https://help.salesforce.com/s/articleView?id=sf.sso_provider_sfdc.htm&type=5)
- [API Library](https://console.cloud.google.com/apis/library)
