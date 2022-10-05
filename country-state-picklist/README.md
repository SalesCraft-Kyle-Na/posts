Hello there! 👋

How to get country state dependent picklists in Apex or LWC?

## Pre Steps

First **required** step is to enable State and Country/territory picklists.

> When you enable state and country/territory picklists, the picklists are immediately available to users.

1. From Setup, enter State and `Country/Territory Picklists` in the Quick Find box, then select `State and Country/Territory Picklists`.
2. Finish [Converting](https://help.salesforce.com/s/articleView?id=sf.admin_state_country_picklists_convert_data.htm&type=5)
3. On the State and Country/Territory Picklists setup page, click `Enable Picklists for Address Fields` to turn on the picklists

You will able to see new fields:
- User
  - User.CountryCode
  - User.StateCode
- Account
  - Account.BillingCountryCode
  - Account.BillingStateCode
- Contact
  - Contact.MailingCountryCode
  - Contact.MailingStateCode
  - Contact.OtherCountryCode
  - Contact.OtherStateCode

[Enable and Disable State and Country/Territory Picklists](https://help.salesforce.com/s/articleView?id=sf.admin_state_country_picklist_enable.htm&type=5)


## LWC
### Standard

- You can use [lightning-record-edit-form](https://developer.salesforce.com/docs/component-library/bundle/lightning-record-edit-form/documentation). Address fields anwill be display automatically.

![billing address picklist](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/10/Screenshot-2022-10-02-at-20.57.52.png)

```html
<template>
    <lightning-record-edit-form object-api-name="Account" record-type-id="012000000000000AAA">
        <lightning-input-field field-name="BillingAddress"> </lightning-input-field>
    </lightning-record-edit-form>
</template>
```
### Custom

```html
<template>
    <lightning-combobox name="country" label="Country" value={selectedCountry} placeholder="Select Country" options={countries} onchange={handleCountry}> </lightning-combobox>
    <lightning-combobox name="state" label="State" value={selectedState} placeholder="Select State" options={states} onchange={handleState}> </lightning-combobox>
</template>
```

```js
import { LightningElement, wire, track } from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import COUNTRY_CODE from '@salesforce/schema/Account.BillingCountryCode';
import BILLING_STATE_CODE from '@salesforce/schema/Account.BillingStateCode';

export default class AddressSelector extends LightningElement {
    _countries = [];
    _countryToStates = {};

    selectedCountry;
    selectedState;

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: COUNTRY_CODE
    })
    wiredCountires({ data }) {
        this._countries = data?.values;
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: BILLING_STATE_CODE })
    wiredStates({ data }) {
        if (!data) {
            return;
        }

        const validForNumberToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));

        this._countryToStates = data.values.reduce((accumulatedStates, state) => {
            const countryIsoCode = validForNumberToCountry[state.validFor[0]];

            return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
        }, {});
    }

    get countries() {
        return this._countries;
    }

    get states() {
        return this._countryToStates[this.selectedCountry] || [];
    }

    handleCountry(e) {
        this.selectedCountry = e.detail.value;
    }

    handleState(e) {
        this.selectedState = e.detail.value;
    }
}
```

## Apex

Let's define wrapper to keep retrived address settings.

```java
public class Country {
    public String label;
    public String value;

    public Country(String label, String value) {
        this.label = label;
        this.value = value;
    }
}

public class State {
    public String label;
    public String value;
    public String dependingOn;

    public State(String label,String value, String dependingOn) {
        this.label = label;
        this.value = value;
        this.dependingOn = dependingOn;
    }
}
```

### Metadata API

- You need to deploy https://github.com/financialforcedev/apex-mdapi
- Use of the Metadata API requires a user with the `ModifyAllData` or `MofifyMetadata` permissions.
- In my opinion it's not the best solution.

```java
public with sharing class AddressSelectorMetadataApi {
    public static Map<String, List<Object>> getAddressSettings() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.CallOptions = new MetadataService.CallOptions_element();
        service.timeout_x = 120000;

        List<MetadataService.AddressSettings> ans = new List<MetadataService.AddressSettings>();

        ans.addAll((List<MetadataService.AddressSettings>) service.readMetadata('AddressSettings', new List<String>{
                'Address'
        }).getRecords());

        MetadataService.AddressSettings addressSettings = ans[0];

        List<Country> countires = new List<Country>();
        List<State> states = new List<State>();

        for (MetadataService.Country country : addressSettings.countriesAndStates.countries) {

            countires.add(new Country(country.label, country.isoCode));

            if (country.states == null) {
                continue;
            }

            for (MetadataService.State state : country.states) {
                states.add(new State(state.label, state.isoCode, country.isoCode));
            }
        }

        return new Map<String, List<Object>>{
            'countries' => countires,
            'states' => states
        };
    }
}
```

### UI API

```java
public with sharing class AddressSelectorUiApi {

    public static Map<String, List<Object>> getAddressSettings() {
        return new Map<String, List<Object>>{
            'countries' => getCountries(),
            'states' => getStates()
        };
    }

    public static List<Country> getCountries() {
        Map<String, Object> uiApiResponse = (Map<String, Object>) JSON.deserializeUntyped(
            AddressSelectorUiApi.callSalesforceUiApi('/services/data/v54.0/ui-api/object-info/Account/picklist-values/012000000000000AAA/BillingCountryCode')
        );

        List<Country> countries = new List<Country>();

        for (Object countryObject : (List<Object>) uiApiResponse.get('values')) {
            Map<String, Object> country = (Map<String, Object>) countryObject;

            countries.add(new Country((String) country.get('label'), (String) country.get('value')));
        }

        return countries;
    }

    public static List<State> getStates() {
        Map<String, Object> uiApiResponse = (Map<String, Object>) JSON.deserializeUntyped(
            AddressSelectorUiApi.callSalesforceUiApi('/services/data/v54.0/ui-api/object-info/Account/picklist-values/012000000000000AAA/BillingStateCode')
        );

        Map<String, Object> countryToValidFor = (Map<String, Object>) uiApiResponse.get('controllerValues');

        Map<Integer, String> validForToCountry = new Map<Integer, String>();

        for (String countryIsoCode : countryToValidFor.keySet()) {
            validForToCountry.put((Integer) countryToValidFor.get(countryIsoCode), countryIsoCode);
        }

        List<State> states = new List<State>();

        for (Object stateObject : (List<Object>) uiApiResponse.get('values')) {
            Map<String, Object> state = (Map<String, Object>) stateObject;
            List<Object> validFor = (List<Object>) state.get('validFor');

            states.add(
                new State(
                    (String) state.get('label'),
                    (String) state.get('value'),
                    (String) (validFor.isEmpty() ? '' : validForToCountry.get((Integer) validFor[0]))
                )
            );
        }

        return states;
    }

    public static String callSalesforceUiApi(String endpoint) {
        String restApiUrl = URL.getOrgDomainUrl().toExternalForm() + endpoint;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(restApiUrl);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

        HttpResponse response = new Http().send(request);

        if (response.getStatusCode() == 200) {
            return response.getBody();
        }

        return '';
    }
}

```
### Result

```json
{
    {
        "states":[
            {
                "value":"AJ",
                "label":"Ajman",
                "dependingOn":"AE"
            },
            {
                "value":"AZ",
                "label":"Abu Zaby",
                "dependingOn":"AE"
            },
            {
                "value":"DU",
                "label":"Dubayy",
                "dependingOn":"AE"
            },
            {
                "value":"FU",
                "label":"Al Fujayrah",
                "dependingOn":"AE"
            },
            {
                "value":"RK",
                "label":"Ra's al Khaymah",
                "dependingOn":"AE"
            },
            {
                "value":"SH",
                "label":"Ash Shariqah",
                "dependingOn":"AE"
            },
            { ... }
        ],
        "countries":[
            {
                "value":"AD",
                "label":"Andorra"
            },
            {
                "value":"AE",
                "label":"United Arab Emirates"
            },
            {
                "value":"AF",
                "label":"Afghanistan"
            },
            {
                "value":"AG",
                "label":"Antigua and Barbuda"
            },
            {
                "value":"AI",
                "label":"Anguilla"
            },
            {
                "value":"AL",
                "label":"Albania"
            },
            {
                "value":"AM",
                "label":"Armenia"
            },
            {
                "value":"AN",
                "label":"Netherlands Antilles"
            },
            {
                "value":"AO",
                "label":"Angola"
            }
            ,
            { ... }
        ]
}
```

## Apex - without dependencies

- Solution below does not provide dependencies between state and country.
- You can find more details here: [Access the state and country picklist through Apex](https://help.salesforce.com/s/articleView?language=en_US&id=000338321&type=1)
- I used `Country` and `State` wrappers mentioned above.

```java
Schema.DescribeFieldResult countryCodeFieldResult = User.CountryCode.getDescribe();

List<Country> countries = new List<Country>();

for (Schema.PicklistEntry countryField : countryCodeFieldResult.getPicklistValues()) {
    countries.add(
        new Country(countryField.getLabel(), countryField.getValue())
    );
}

System.debug(countries);

Schema.DescribeFieldResult stateCodeFieldResult = User.StateCode.getDescribe();

List<State> states = new List<State>();

for (Schema.PicklistEntry stateField : stateCodeFieldResult.getPicklistValues()) {

    states.add(
        new State(stateField.getLabel(), stateField.getValue(), '')
    );
}

System.debug(states);
```

## Resources

- [Access the state and country picklist through Apex](https://help.salesforce.com/s/articleView?language=en_US&id=000338321&type=1)
- [Get Values for a Picklist Field](https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_resources_picklist_values.htm)
- [Enable and Disable State and Country/Territory Picklists](https://help.salesforce.com/s/articleView?id=sf.admin_state_country_picklist_enable.htm&type=5)
- [Build UI for Picklists](https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_features_records_dependent_picklist.htm)
- [AddressSettings](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_addresssettings.htm)
- [Apex Wrapper Salesforce Metadata API](https://github.com/financialforcedev/apex-mdapi)
