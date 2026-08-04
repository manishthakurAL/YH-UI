import { LightningElement, api, track } from 'lwc';
import iframeUrlLabel from '@salesforce/label/c.LocatorPlusURL';

export default class LocatorPlusIframe extends LightningElement {
    @api portalRepairsEmail;
    @track iframeUrl;

    connectedCallback() {
        this.updateIframeUrl();
    }

    renderedCallback() {
        this.updateIframeUrl();
    }

    updateIframeUrl() {
        const baseUrl = iframeUrlLabel;
        if (this.portalRepairsEmail) {
            this.iframeUrl = baseUrl+'&setmail='+this.portalRepairsEmail;
        } else {
            this.iframeUrl = baseUrl;
        }
    }

}