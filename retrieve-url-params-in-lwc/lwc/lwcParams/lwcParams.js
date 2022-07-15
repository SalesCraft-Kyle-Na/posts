import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class LwcParams extends LightningElement {
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
