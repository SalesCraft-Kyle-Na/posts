Hi guys,
Today I gonna show you how to define a custom data type in lightning-datatable and how to use it.

## What lightning-datatable is?

> A table that displays rows and columns of data. ~ Salesforce

![datatable](https://salesforceprofs.com/wp-content/uploads/2020/05/image-4-1024x188.png)

We have many predefined types like:

- action
- boolean
- button
- button-icon
- currency
- date
- date-local
- email
- location
- number
- percent
- phone
- text
- URL

but sometimes we will have to create our own type to fulfill the client\'s requirements.

## Architecture

![custom](https://salesforceprofs.com/wp-content/uploads/2020/05/image-7.png)

## How to define a custom type?

![Custom](https://salesforceprofs.com/wp-content/uploads/2020/09/image-1024x307.png)

### 1. Create a Custom Data Type component

.HTML file contains how table cell will look like. It can be whatever you want. e.g button, picklist, link, etc.

```html
<template>
    <button onclick={fireCustomTypeA}>
        CustomTypeA - {customValueA}
    </button>
</template>
```

.js file contain typeAttributes and event, which is fire after cell click. Of course, onclick is optional, you can just display data, without custom event sent to parent.

```js
import { LightningElement, api } from 'lwc';

export default class CustomTypeA extends LightningElement {

    @api recordId;
    @api customValueA;

    fireCustomTypeA() {
        let newCustomValueA = this.customValueA + 1;
        const event = new CustomEvent('customtypea', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                recordId: this.recordId,
                newCustomValueA: newCustomValueA
            },
        });
        this.dispatchEvent(event);
    }
}
```

### 2. Creating a Custom Type Template

`.HTML` file, which using custom type component created in step number 1. If our component contains some public properties, they can be pass here.
The file should be created in the same place (folder) as the custom lightning datatable described in step 3.

**Important!**
*value* is what we used in *key-field=FIELD* in step 4 HTML.
Usually, it is the record Id: *key-field=Id*. This is why in my example I assigned value to record-id.

```html
<template>
    <c-custom-type-a
        record-id={value}
        custom-value-a={typeAttributes.customValueA}
    ></c-custom-type-a>
</template>
```

### 3. Create Custom Lightning Datatable

Out custom datatable, which import templates created in step 2, and configuration for them.

```js
import LightningDatatable from 'lightning/datatable';
import customTypeA from './customTypeA';
import customTypeB from './customTypeB';

export default class CustomLightningDatatable extends LightningDatatable {
    static customTypes = {
        customTypeA: {
            template: customTypeA,
            typeAttributes: ['recordId', 'customValueA']
        },
        customTypeB: {
            template: customTypeB,
            typeAttributes: ['recordId']
        }
    }
}
```

#### 4. Use Custom Lightning Datatable

Use case of the custom data table created in step 3. It contains all standard properties (the same as standard datatable) and our own like custom events.

```html
<template>
    <c-custom-lightning-datatable key-field="id"
                                  data={data}
                                  columns={columns}
                                  hide-checkbox-column
                                  oncustomtypea={handleCustomTypeA}
                                  oncustomtypeb={handleCustomTypeB}>
    </c-custom-lightning-datatable>
</template>
```

```js
import { LightningElement, track } from 'lwc';

export default class MyDataTable extends LightningElement {

    columns = [
        { label: 'Record Name', fieldName: 'name', type: 'text'},
        { label: 'Custom Type A', fieldName: 'id', type: 'customTypeA', typeAttributes: {
                customValueA: { fieldName: 'customA' }
            }
        },
        { label: 'Custom Type B', fieldName: 'id', type: 'customTypeB', typeAttributes: {
                customValueB: { fieldName: 'customB' }
            }
        }
    ];

    @track data = [
        { id: 1, name: 'Example 1', customA: 1, customB: 11, createdDate: '08-05-2020 '},
        { id: 2, name: 'Example 2', customA: 2, customB: 12, createdDate: '08-05-2020 '},
        { id: 3, name: 'Example 3', customA: 3, customB: 13, createdDate: '08-05-2020 '},
        { id: 4, name: 'Example 4', customA: 4, customB: 14, createdDate: '08-05-2020 '},
        { id: 5, name: 'Example 5', customA: 5, customB: 15, createdDate: '08-05-2020 '},
        { id: 6, name: 'Example 6', customA: 6, customB: 16, createdDate: '08-05-2020 '},
        { id: 7, name: 'Example 7', customA: 7, customB: 17, createdDate: '08-05-2020 '},
        { id: 8, name: 'Example 8', customA: 8, customB: 18, createdDate: '08-05-2020 '}
    ];

    handleCustomTypeA(event) {
        const { recordId, newCustomValueA } = event.detail;
        console.log('CUSTOM TYPE A - ' + recordId + ' - ' + newCustomValueA);
        this.data.find(item => item.id == recordId).customA = newCustomValueA;
        this.data = [...this.data];
    }

    handleCustomTypeB(event) {
        const { recordId, customValueB } = event.detail;
        console.log('CUSTOM TYPE B - ' + recordId);
    }
}
```

## Repository

[Github](https://github.com/pgajek2/custom-lightning-datatable-type)

---

If you have some questions feel free to ask in the comment section below. :)

Was it helpful? Check out our other great posts [here](https://beyondthecloud.dev/blog).

---

## Resource

1. [https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/example](https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/example)
2. [https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.events_propagation](https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.events_propagation)
