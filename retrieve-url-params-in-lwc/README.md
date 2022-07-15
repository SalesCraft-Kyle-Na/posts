Hello Folks,
Today I wanna show you how to get URL parameters in the **LWC** component using **CurrentPageReference**.

Let\'s get started.

## Get URL parameters in LWC

The easiest way to get url params will be to use **CurrentPageReference**.

- *currentPageReference.state* - contains the key - value pairs of URL query parameters.
- *currentPageReference.state.parameterName* - allows to get specific param from URL.

![lwc-url-params](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/07/lwc-url-params.png)

```js
// currentPageReference
{
   attributes: {
      name: URL_Test_Page__c
   },
   state: {
      lang: en_US,
      type: test-type,
      id: 000000000001
   },
   type: comm__namedPage
}
```

As you can see in the code above - **currentPageReference** includes page API Name and [type](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/reference_page_reference_type).

Reference page types that are supported:

- App - **standard__app**
- Lightning Component - **standard__component**
- Knowledge Article - **standard__knowledgeArticlePage**
- Login Page - **comm__loginPage**
- Named Page (Communities) - **comm__namedPage**
- Named Page (Standard) - **standard__namedPage**
- Navigation Item Page - **standard__navItemPage**
- Object Page - **standard__objectPage**
- Record Page - **standard__recordPage**
- Record Relationship Page - **standard__recordRelationshipPage**
- Web Page - **standard__webPage**

**Assumptions**

- Since the key-value pairs of `PageReference.state` are serialized to URL query parameters, all the values must be strings.
- **@wire service getStateParameters will be fire automatically every time URL params will change.**

## Code

```js
import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class MyComponentName extends LightningElement {

    urlId = null;
    urlLanguage = null;
    urlType = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlId = currentPageReference.state?.id;
          this.urlLanguage = currentPageReference.state?.lang;
          this.urlType = currentPageReference.state?.type;
       }
    }
}
```

Was this helpful? Check out our other great posts [here](https://www.beyondthecloud.dev/blog).

## Resources

- [Navigation - CurrentPageReference](https://developer.salesforce.com/docs/component-library/bundle/lightning-navigation/documentation)
- [Add Query Parameters](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/use_navigate_add_params_url)l
