## Introduction ##
Hello, devs!

This is my first post, so I would like to have some fun and create a Hangman game using Lightning Web Components. Hangman is a single-player guessing game. The player has to guess the word, phrase or sentence by suggesting letters within a certain number of guesses.
This will be a small project, however, the goal of this post is to show some basic OOP concepts using JavaScript. I hope it could be helpful for developers who are more interested in Apex but also want to get some hands-on experience with LWC and JS. Let\'s start!

## Prepare the environment
To follow everything described in this post you will need a Dev Hub and VS Code installed on your machine. Of course, any IDE would do the job however, I\'ve chosen VS Code for this task because it allows previewing your LWC development progress easily thanks to lwc-development-server. Let\'s create a scratch org first. If you don\'t have your instance of Developer Org, you can get one for free here: https://developer.salesforce.com/signup

Open VS Code and create a new SFDX Project (use CTRL + SHIFT + P and type: SFDX: Create Project), when asked, choose the standard template, type the name of the project (for me its lwc-hangman) and then authenticate to your Dev Hub environment.

Assuming that you are authenticated to an org with Dev Hub enabled (https://help.salesforce.com/s/articleView?id=sf.sfdx_setup_enable_devhub.htm&amp;type=5) type the following command in your CLI:

```
sfdx force:org:create -f config/project-scratch-def.json -a HangmanScratchOrg --setdefaultusername
```

Usually, it takes up to 3 minutes to spin up a new scratch org, once it\'s done you will see the following notification in your CLI:

```
Successfully created scratch org: 00D1x000000HloyEAC, username: test-9jdflpbvch3u@example.com

```

A newly created scratch org should be set as the default org in your project now:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-00.png)

We will create our first component and check if the Local Development server is set up correctly.

Use CTRL + SHIFT + P combination and type SFDX: Create Lightning Web Component. Choose any name you want, however, I recommend using the name \'hangman\' to follow the content of this blog easily.

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-01.png)

Let\'s open the newly created file hangman.html and put some hello world there to see if the Preview Component Locally command would work:

*hangman.html*
```
<template>
    <p>Hello BeyondTheCloud</p>
</template>
```

Save the component and then right-click on the hangman.html file and choose an option: \"SFDX: Preview Component Locally\"

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-02.png)

If nothing happens, please check the message in the CLI terminal, most likely @salesforce/lwc-dev-server-plugin is not installed on your machine.

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-03.png)

Go to https://developer.salesforce.com/tools/vscode/en/localdev/set-up-lwc-local-dev to find detailed instructions how to install LWC Local Development Server. When LWC Local Development is set up correctly, after choosing SFDX: Previev Component Locally and selecting the Use Desktop Browser the effect should be as below:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-04.png)

Now change the code a little bit (eg. add \'!\' after Hello BeyondTheCloud) and save the command. Check the browser window and see that component was re-rendered automatically!

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-05.png)

## Start the development ##

We have the developer environment prepared, now finally we can start actually coding the game. Let\'s make our first design decision: we want to avoid putting all of the logic in the hangman.js game, to achieve that let\'s keep the game logic in separate file, and allow the hangman.js to start the game:

1. Create new file in our hangman LWC component:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-06.png)

2. Add Game class to the new file and export it:

*game.js*
```js
class Game {

    constructor() {
        console.log('Hangman game is starting');
    }

}
export { Game };
```

3. Import the game.js class in hangman.js file, and invoke the Game constructor in connectedCallback() hook:

*hangman.js*
```js
import { LightningElement } from 'lwc';
import { Game } from './Game.js';

export default class Hangman extends LightningElement {
    connectedCallback() {
        console.log('CONNECTED CALLBACK');
        const game = new Game();
    }
}
```

Save the file, and check the console logs in your browser. LWC development server should automatically rebuild the project, so there is no need to refresh. You should see following output in Console:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-07.png)

Congratulations! This game starts working, however is not that fun yet :)
FYI: if you want to track the project code state step by step, please see the repository here: https://github.com/beyond-the-cloud-dev/lwc-hangman I created a commit for each step that is showed here, so it\'s very easy to revert the project to any step described in this post.

## Import static resources and display the initial state of the game ##

Now, lets build the initial game screen. We need to display:
a) Picture showing the current round (a gallows)
b) Phrase to be guessed (passphrase)
c) Buttons with all letters to let player guess the passphrase 

1. Clone the project repository, get the static resources and deploy them to your org:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-08.png)

You can do that for example via CLI using following command:
```
sfdx force:source:deploy -p force-app\main\default\staticresources -u "HangmanScratchOrg"
```
You should see following output:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-09.png)

2. Images contains the 7 images representing the state of the game. For the beginning we will display statically the last one and add the logic to change the picture later:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-10-300x253.png)

3. Import static resources into the game.js and create the method to expose the URL link to the picture in the Game class:

*Game.js*
```js
import ROUND_IMAGES from '@salesforce/resourceUrl/hangmanResources';
```

```
    get imageUrl() {
        return ROUND_IMAGES + '/images/round-7.png';
    }
```

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-11.png)

4. We have to use game instance to expose this value to the template file.

*hangman.js*
```js
    connectedCallback() {
        console.log('CONNECTED CALLBACK');
        const game = new Game();
        this.imageUrl = game.imageUrl;
    }
```
5. Now add some html element with a little bit of styling to show the image. You can remove the previously added \<p> tag because we don\'t need it anymore.

*hangman.html:*
```
<img class="slds-align_absolute-center" style="max-height: 22rem" src={imageUrl}>
```
Let\'s save the changes and take a look on a browser window:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-13.png)

## Add letters to layout ##

1. We have to create 26 buttons for each alphabet letter to allow the player to guess the sentence. First, we will declare the array containing all needed letters. We can do it in a boring way:

```
letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

```

But I\'m too lazy to type all of that in my IDE, so I decided to find out some other way to achieve that. We can use the char codes and native array methods to do this without implicitly listing all alphabet letters:
 

*game.js:*
```js
letters = Array.from(Array(26))
        .map((e, i) => i + 65)
        .map((x) => String.fromCharCode(x));
```

let\'s go step by step through the provided code

```js
Array.from(Array(26))
```
Array(26) created an empty array with 26 slots. Be aware that they are not actual undefined elements, they are literally empty slots, and as a consequence, we cannot iterate through them using the map method. That\'s why we\'ll use ES6 Array.from() method to create an Array of undefined elements from an array of empty slots.

```js
.map((e, i) => i + 65)
```
We have an array containing 26 undefined elements, that\'s not so useful, so I\'m using the map method to iterate through the collection and replace each of the collection elements with a number, which represents the char code for the alphabet letters (https://www.rapidtables.com/code/text/ascii-table.html) - the letter \'a\' is represented by number 65.

```js
.map((x) => String.fromCharCode(x));
```

The last step is to iterate through the collection again and use the native String.fromCharCode() function to replace codes with the letters. Actually steps 2 and 3 could be done in one iteration, to see how it looks, check the code repository. Put the letters variable inside the Game class.

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-14.png)

2. Now we have to create buttons based on the letters provided by Game:

*hangman.js:*
```js
    get letters() {
        return this.game.letters;
    }
```

3. We\'ll use a template for:each directive to create a list of elements. We could do this using the standard JavaScript DOM manipulating method but the standard LWC templating system is a better choice (see https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.create_lists for reference)
I\'m adding for:each template after the \<img> tag in HTML file:
*hangman.html:*
```
    <template for:each={letters} for:item="l">
        <div key={l}>
            <button>{l}</button>
        </div>
    </template>
```
We are iterating over an array of letters exposed by hangman.js. For each element in the array, we will simply display the standard HTML button.
Unfortunately, when the browser refreshes automatically, nothing is displayed. Let\'s check the console  to see if there is any information there:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-15.png)

If we take a look at the code in hangman.js again we will see that VS Code actually tried to warn us. See that game reference in letter getter has a small underline. Hover over it to see what is the problem here:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-16.png)

The reason behind get letter() not accessing the game variable is variable scoping. Variables declared with the keyword const (and let) are block-scoped, which means that they are only visible within the block they are declared in (block could mean class, function, if-else block).

However, changing the const keyword to var is not a solution in this case. This is because variables declared with keyword var are global or function scoped. This means that if they are declared outside of the function, they are added to the global scope, and can be reused anywhere in the code. In our case, they are declared within a function and their scope is limited only to that function. (to learn all of the differences between the type of the variables I would highly recommend this article:  https://www.freecodecamp.org/news/var-let-and-const-whats-the-difference/)

4. This issue can be solved easily. A game variable needs to be declared on a class instance. In this case, we can use the keyword *this* which is the reference to the current class. As we are in the context of the Hangman class, anything declared this way will be available to all other methods:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-17.png)

Don\'t forget to update the game.imageUrl reference in line 9. As the game instance is now declared on the class level, not in a function scope, we need to refer to it correctly.
You can see that line 13 has no underline. This might mean that the issue is solved, lets\'s check the browser window to see if it is already fixed:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-18.png)

5. Since we are using standard HTML button elements, they don\'t have the slds styling out-of-the-box. Let\'s add a little bit of colour and style to them:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-19.png)

I\'m using standard slds classes to create a grid and columns to apply standard slds button styling. I\'m also adding a little bit of custom CSS styling in the newly created hangman.css file:

*hangman.css:*
```css
.letter {
    max-width: 2.5rem !important
}
```

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-20.png)

Looks much better, right?
Now, we are missing the last element of the layout: the passphrase

## Add passphrase to layout ##

1. We\'ll create new Class to separate logic related to the passphrase from the game:

*passprhase.js:*
```js
class Passphrase {}
export { Passphrase };
```
2. Game.js will create a new Passphrase every time a new game is started. This sounds like a job for a constructor, so let\'s create one for a Passphrase class, and add some logic, here is the code:

*passprhase.js:*
```js
class Passphrase {

    constructor() {
        let randomPassphrase = this.drawPassprhase();
        this.value = randomPassphrase.value;
        this.category = randomPassphrase.category;
    }

    drawPassprhase() {
        return availablePassphrases[Math.floor(Math.random() * availablePassphrases.length)];
    }
}

const availablePassphrases = [
    { value: "Salesforce Marketing Cloud", category: "Salesforce Clouds" },
    { value: "Beyond The Cloud", category: "Top Blogs"},
    { value: "Lightning Web Components", category: "Frameworks"},
    { value: "Dreamforce", category: "Events"},
]

export { Passphrase };
```

Let\'s explain step by step what is going on. In the constructor, I\'m using drawPassphrase() method to get some random passphrase. In the future, I could refactor this method to get the passwords from database, static resources, external APIs or any other resource. For the sake of simplicity, I hardcoded a few example passphrases directly in the Passphrase file. Please notice that this variable is not going to be exported, so we can consider this one as \'hidden\', which means that no other class than Passphrase could get all available passphrases.

Draw passphrase method is using native JS Math module to return a pseudo-random number between 0 and 1 (greater or equal than 0, but less than one, so it could never be 1, this fact is important for us). Then a random number is multiplied by the availablePassphrase length, which means that we can get any value greater than zero and lower than array length and rounded down.  In our case, we will always get one of the array indexes (0, 1, 2 ... ) no matter how many passphrases will be added to the array.

3. We can use new constructor in game.js:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-21.png)

Save both Passphrase and Game files, and check the developer console

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-21-1.png)

4. It seems that the Passphrase class works as expected. But we don\'t want to expose the password to the user, Passphrase class needs to implement some masking and unmasking mechanism. When the class instance is invoked, we want to create a masked version of the passphrase. I\'ll keep it simple:

*game.js:*
```js
    get maskedPassphrase() {
        return this.maskedValue;
    }

    maskPassphrase() {
        let masked = "";
        for (const char of this.value) {
            if (this.checkedLetters.includes(char.toUpperCase()) || char == " ") {
                masked += char;
            } else {
                masked += "_";
            }
        }
        return masked;
    }
```
I\'m also adding new line to the constructor:

*game.js*
```
this.maskedValue = this.maskPassphrase();
```
Console output should contain now new property on passphrase instance:
![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-21-2.png)

5. Now I want to deliver the passphrase and category value to the layout. I'm achieving that by creating two new getters:

*game.js:*
```js
    get passphrase() {
        return this.game.maskedPassphrase;
    }
    get category() {
        return this.game.category;
    }
```

In hangman.js file we will create one getter, property and modify the constructor a little bit:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-22.png)

Take a look at the hangman.js file content. We decided at the very beginning we would like to keep here only logic to render the game, and it looks that so far we are doing a good job. All game-related logic is hidden from hangman.js

6. Masked passphrase and category should be displayed on the layout. Add them right after the \<img> tag:

*hangman.html:*
```
    <div class="slds-p-bottom_medium">
        <div class="slds-box">
            <div class="slds-text-heading_large slds-text-align_center">{passphrase}</div>
            <div class="slds-text-heading_medium slds-text-align_center slds-p-top_medium">Category: {category}</div>
        </div>
    </div>
```

## Add game logic ##

Finally, the time has come to add some moving parts to the game. When the player clicks on any of the letters the game should react:
<ul>
<li>button becomes inactive</li>
<li>if the guessed letter does not occur in the passphrase, the game round should be increased and the picture should change</li>
<li>if the guessed letter does occur in the passphrase, it should be revealed</li>
</ul>

1. Lets add onClick event handler to the buttons on layout and handle it in js
![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-23.png)

2. We need to disable the button immediately after it is clicked. This is a logic related to game rendering so I\'m going to handle this directly in hangman.js file

*hangman.js:*
```js
    handleButtonClick(event) {
        event.target.disabled = true;
    }
```
3. The next step is to handle the game logic. We should check if the passphrase contains the chosen letter. If yes, we want to reveal that letter in the passphrase. Checking if the passphrase contains the letter selected by the player should be delegated to the Passphrase class. In Passphrase class we will keep the array of the letters that were checked by the player:

```
checkedLetters = [];
```
4. We will modify the maskPassphrase() function to check the array checkedLetters, and do not hide the letters in passphrase if they were already checked by player:

*passphrase.js:*
```js
    maskPassphrase() {
        let masked = "";
        for (const char of this.value) {
            if (this.checkedLetters.includes(char.toUpperCase()) || char == " ") {
                masked += char;
            } else {
                masked += "_";
            }
        }
        return masked;
    }
```

5. The last change in the passphrase.js is adding a function which will actually check if the passphrase contains the letter guessed by the user. If yes, the value of maskedPassphrase should be updated. The function returns true if the passphrase contains the guessed letter

*passphrase.js:*
```js
    checkLetter(letter) {
        this.checkedLetters.push(letter);
        if (this.value.toUpperCase().includes(letter)) {
            this.maskedValue = this.maskPassphrase();
            return true;
        };
        return false;
    }
```
6. The next step is to call the checkLetter function. We don\'t want to do that directly from hangman.js file, because it is not even aware that the Passphrase class exists. It is communicating only with the Game class to check the state of the game and render it. That's why we\'ll create another check letter function in Game class:

*game.js*
```js
    checkLetter(letter) {
        this.passphrase.checkLetter(letter);
    }
```
7. checkLetter() is going to be invoked by handleButtonClick() method that was created earlier in hangman.js.  In case the masked passphrase is changed, we should refresh the passphrase manually. The following lines should be added:

*hangman.js*
```
this.game.checkLetter(event.target.textContent);
this.passphrase = this.game.maskedPassphrase;
```
event.target refers to the DOM element that emitted the handled event. We can use that to extract a lot of information about the source of the event and the event itself. All we need to know in our use case is what was the letter on the clicked button.

8. When user clicks on any letter and passphrase contains that letter, game should  now reveal letters in passphrase:
![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-24.png)

9. If we miss the shot, the picture should be changed. At this moment we are displaying a static image (see get imageUrl()) but the goal is to change the picture dynamically when the round number is increased. We need to create a property in Game class to store the number:

*game.js*
```js
    round = 0;
```

10. Now we want to increase the round number when letter is not a part of passphrase. Let\'s add following logic to checkLetter method:

*game.js*
```js
    checkLetter(letter) {
        const passphraseContainsLetter = this.passphrase.checkLetter(letter); 
        if (!passphraseContainsLetter) {
            this.nextRound();
        }
    }
    nextRound() {
        return this.round++;
    }
```
11. The last change will be to modify imageUrl getter to return a value based on the round number. We\'ll use that opportunity to do a small refactor. We will replace string concatenation with string literals which in our use case serves the same purpose and looks a little bit fancier

*game.js*
```js
    get imageUrl() {
        return `${ROUND_IMAGES}/images/round-${this.round}.png`;
    }
```

12. We have to make sure that when the round number is increased, the picture rendered on the layout will be also changed:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-25.png)

13. Let's check the browser to see if this works, you should be able to see 0 round image at the beginning, and it should be changed every time a checked letter does not occur in the passphrase

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-26.png)

## Add end game screen ##
1. If the player makes enough incorrect guesses (in our case the number is 7) player should lose the game. Two new functions in Game class need to be implemented to check the state game after each guess:

*game.js*
```js
    isGameWon() {
        return this.passphrase.value === this.passphrase.maskedValue;
    }
    isGameLost() {
        return this.round >= NO_OF_ROUNDS;
    }
```
2. If all letters are guessed correctly, then the masked value will be equal to the passphrase value. On the other hand, if the round number is equal to or bigger than the number of rounds, the game is lost. Let's declare this number as constant outside the Game class: 

*game.js*
```
const NO_OF_ROUNDS = 7;
```
3. We will create getters in hangman.js to expose the information about game state to the html template:
*hangman.js*
```js
    get isGameFinished() {
        return this.game.isGameWon() || this.game.isGameLost();
    }
    get endGameText() {
        return this.game.isGameWon() ? 'Congratulations, You win! do you want to try again?' : 'You lose the game, do you want to try again?';
    }
```

4. And then use true/false directive to display the elements of the UI dynamically. When the game is finished, a box with a message and a button to restart the game is displayed instead of buttons with letters.

*hangman.html*
![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-27.png)

5. Last thing to do is to handle the restart button. We have to bring back the initial state of the game which means:
<ul>
<li>to create new instance of the game</li>
<li>set the picture representing round 0</li>
<li>set new passphrase</li>
<li>display the buttons with letters again</li>
</ul>

In the currently existing constructor, we are already doing the things mentioned in points a, b and c. Let\'s refactor the constructor a little bit to reuse the existing logic:

*hangman.js*
![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-28.png)

6. The end game screen is ready. When the game is finished it should look like the screenshot below:

![](https://wordpress.beyondthecloud.dev/wp-content/uploads/2022/09/hangman-29.png)

## Summary ##
We went step-by-step through the process of creating a simple game in Lightning Web Components. We learn how to use basic concepts of Oriented Object Programming, and leverage the Local Development Server to speed up the development process.

If you like this post and want to see more posts like this in the future feel free to let us know in the comments section :)

## Repository ##
[GitHub](https://github.com/beyond-the-cloud-dev/lwc-hangman)

## Resources ##

- [Enabling a Dev Hub](https://help.salesforce.com/s/articleView?id=sf.sfdx_setup_enable_devhub.htm&amp;type=5)
- [LWC Local Development](https://developer.salesforce.com/tools/vscode/en/localdev/lwclocaldev)
- [Var, let and const, what\'s the difference](https://www.freecodecamp.org/news/var-let-and-const-whats-the-difference/)
- [Constructing an array](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Array)
- [Charcode tables](https://www.rapidtables.com/code/text/ascii-table.html)
- [LWC HTML Templates](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.create_lists)
- [JS Math.random() method](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random)