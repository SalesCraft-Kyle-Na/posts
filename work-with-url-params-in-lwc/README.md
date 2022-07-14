Hello Devs,
Today I would like to explain to you how we can work with navigation parameters in Lightning Web Components.
Let\'s get started!

## Demo

I created a simple community page with custom navigation. When the user clicks on the navigation item c__page param in the URL will change. Based on URL c__page param highlighted navigation item change and Current Page information display different values.

![Demo](https://salesforceprofs.com/wp-content/uploads/2021/01/image-1024x338.png)Demo## LWC Code

.html

```js
<template>

    <lightning-vertical-navigation selected-item={newPageId}>
        <lightning-vertical-navigation-section label=Navigation selected-item={newPageId}>
            <template for:each={navigationItems} for:item=navigationItem>
                <lightning-vertical-navigation-item key={navigationItem.pageId} label={navigationItem.label} name={navigationItem.pageId} onclick={handleNavigate}></lightning-vertical-navigation-item>
            </template>
        </lightning-vertical-navigation-section>
    </lightning-vertical-navigation>

    <p>Current Page is <strong>{newPageId}</strong></p>

</template>
```

.js

```js
import { LightningElement, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

const NAVIGATION_ITEMS = [
    { label: 'Home', pageId: 'home', isCurrentPage: false },
    { label: 'PageA', pageId: 'pageA', isCurrentPage: false },
    { label: 'PageB', pageId: 'pageB', isCurrentPage: false },
    { label: 'PageC', pageId: 'pageC', isCurrentPage: false },
];

export default class LwcNavigation extends NavigationMixin(LightningElement) {

    currentPageReference;
    selectedPageId;
    newPageId = 'home';
    navigationItems = NAVIGATION_ITEMS;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            this.currentPageReference = currentPageReference;
            this.setCurrentPageIdBasedOnUrl();
        }
    }

    get newPageReference() {
        return Object.assign({}, this.currentPageReference, {
            state: Object.assign({}, this.currentPageReference.state, this.newPageReferenceUrlParams)
        });
    }

    get newPageReferenceUrlParams() {
        return {
            c__page: this.selectedPageId
        };
    }

    setCurrentPageIdBasedOnUrl() {
        this.newPageId = this.currentPageReference.state.c__page;
    }

    handleNavigate(event) {
        this.selectedPageId = event.target.name;

        this.navigateToNewPage();
    }

    navigateToNewPage() {
        this[NavigationMixin.Navigate](
            this.newPageReference,
            false // if true js history is replaced without pushing a new history entry onto the browser history stack
        );        // if false new js history entry is created. User will be able to click browser back/forward buttons
    }
}
```

- Line 16: Our Navigation is dynamically created based on NAVIGATION_ITEMS created before class declaration.
- Line 19: **setCurrentPageReference method is fire every time that c__page will change**. We can use it to set the current pageId in Line 39.
- Line 27: *The currentPageReference property is read-only. To navigate to the same page with a modified state, copy the currentPageReference and modify the copy.*
- Line 34: newPageReferenceUrlParams is used to prepare new states in URL.
  **Remember!** `<em>state</em>` *properties must use a namespace prefix followed by two underscores,* `<em>__</em>`*. If the component isn’t part of a managed package, use* `<em>c</em>` *for the namespace prefix. If the component is part of a managed package, use the package\'s namespace.* *To delete a value from the* `<em>state</em>` *object, define it as* `<em>undefined</em>`*.*
- Line 51: \'replace\' argument - if false page state will change with pushing a new history entry into the browser history stack. It allows working with back/forward buttons.

## Summary

As you can see, working with URL parameters in Lightning Web Components is not hard. The above approach allows us to create quite a nice Single Page Application (SPA) using standard salesforce NavigationMixin functionality.
We can also use it to generate page links, which improve User Experience, not just replace page content.

 Was this helpful? Check out our other great posts [here](https://salesforceprofs.com/blog).

## References

- [https://developer.salesforce.com/docs/component-library/documentation/en/lwc/use_navigate_add_params_url](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/use_navigate_add_params_url)
