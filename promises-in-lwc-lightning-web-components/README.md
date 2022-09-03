Hello folks!

What is JavaScript Promise? How does it work with Lightning Web Component? What is the better choice to resolve promises in LWC?

Well, let's get down to the details.

## Introduction

**Javascript is a single threaded.**

- *What does it mean?*

Only one operation at a time. Code is executed line by line.

![js](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/js.gif)

- *What is the problem with this approach?*

UI (your browser window) can freeze at the time of code execution. Is really bad from the user experience perspective.

- *How we can resolve it?*

Asynchronous JavaScript!
You will get a **Promise** that code will be done some time in the future. You don't know when, but you will be able to detect it (then or await).

![js-promise](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/js-promise.gif)

## Promise

> **Promise** lets asynchronous methods return values like synchronous methods: instead of immediately returning the final value, the asynchronous method returns a promise to supply the value at some point in the future. ~ MDN

A Promise is in one of these states:

- **pending**: initial state, neither fulfilled nor rejected.
- **fulfilled**: meaning that the operation was completed successfully.
- **rejected**: meaning that the operation failed.

Each state fires an associated handler.

![javascript promise](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/h3o8Po7q0GDc.png)

## Code

```js
let shouldBeResolve = true;

const promise = new Promise((resolve, reject) => {
  setTimeout(() => {
      if (shouldBeResolve) {
          resolve('success!');
      }

      reject('failed!');
  }, 1000);
});

// then/catch
const thenCatchApproach = () => {
  promise
    .then((result) => {
      console.log(`thenCatchApproach result => ${result}.`);
    })
    .catch((error) => {
      console.log(`thenCatchApproach error => ${error}.`);
    })
    .finally(() => {
      console.log('thenCatchApproach done.');
    })
}


// async/await
const asyncAwaitApproach = async () => {
  try {
    const result = await promise;
    console.log(`asyncAwaitApproach result => ${result}.`);
  } catch (error) {
    console.error(error);
    console.log(`asyncAwaitApproach error => ${error}.`);
  } finally {
    console.log('asyncAwaitApproach done.');
  }
}

// success
shouldBeResolve = true;

thenCatchApproach();
asyncAwaitApproach();

// error
// shouldBeResolve = false;

// thenCatchApproach();
// asyncAwaitApproach();
```

## Promises in LWC

**All apex functions return a promise.**

```js
import apexMethodName from '@salesforce/apex/Namespace.Classname.apexMethodReference';
```

> The imported function returns a promise. ~ Salesforce

 We can resolve the apex method in three ways:
- `@wire`
- Then/Catch
- Async/Await

### Wire

#### When to use?
- Result can be cached. To use `@wire` apex method needs to be marked as `(Cacheable=true)`.
- `@wire` is great to read the data. **DML (insert, update, delete) operations are not supported.**

#### Code

- Wire an Apex Method to a Property

```js
import apexMethodName from '@salesforce/apex/Namespace.Classname.apexMethodReference';

@wire(apexMethodName, { apexMethodParams })
property;
```

- Wire an Apex Method to a Function

```js
import apexMethodName from '@salesforce/apex/Namespace.Classname.apexMethodReference';

@wire(apexMethodName, { apexMethodParams })
wiredFunction({ error, data }) {
	if (data) {
		console.log(data);
	} else if (error) {
		console.error(error);
	}
}
```

### Then/Catch

### When to use?
- Operation on the database is needed (DMLs - insert, update, delete).
- Data cannot be cached.
- Apex should be invoked after user action (e.g. onclick).
- Resolve order is **not needed**. You can chain methods, but code is hard to read and understand. It's better to use `async/await`.

#### Code

```js
import apexMethodName from '@salesforce/apex/Namespace.Classname.apexMethodReference';

apexMethodName
	.then(result => {
		console.log(result);
	})
	.catch(error => {
		console.error(error);
	})
	.finally(() => {
		console.log('done.'); //good place to hide spinner
	})
```

### Async/Await

#### When to use?
- Operation on the database is needed (DMLs - insert, update, delete).
- Data cannot be cached.
- Apex should be invoked after user action (e.g. onclick).
- When resolve order is **needed**. You can chain methods and make code easy to read.
- Async/await is an excellent option if you find yourself writing long, complicated waterfalls of `.then` statements.

#### Code

```js
import apexMethodName from '@salesforce/apex/Namespace.Classname.apexMethodReference';

try {
	let result = await apexMethodName;
catch (error) {
	console.error(error);
} finally {
	console.log('done.'); //good place to hide spinner
}
```

- Chain Execution

```js
import { LightningElement } from 'lwc';

import apexMethod1 from '@salesforce/apex/ClassName.apexMethod1';
import apexMethod2 from '@salesforce/apex/ClassName.apexMethod2';
import apexMethod3 from '@salesforce/apex/ClassName.apexMethod3';

export default class LwcPromise extends LightningElement {

    connectedCallback() {
        this.invokeApexMethods();
    }

    async invokeApexMethods() {
        try {
            const result1 = await apexMethod1();
            const result2 = await apexMethod2({ param: result1 });
            const result3 = await apexMethod3({ param: result2 });
        } catch(error) {
            console.error(error);
        } finally {
            console.log('Finally Block');
        }
    }
}
```

#### Consideration
- Async function always returns a promise.

```js
async function myAsyncFunction() {
    return 'hello async promise!';
}

myAsyncFunction().then(result => console.log(result));  //hello async promise!
//or
await myAsyncFunction(); //hello async promise!
```

- Await can be used only in a method signed as `async`.

---

If you have any questions feel free to ask in the comment section below. :)

Was it helpful? Check out our other great posts [here](https://beyondthecloud.dev/blog).

---

## Resources
- [Call Apex Methods Imperatively](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.apex_call_imperative)
- [async function](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function)
