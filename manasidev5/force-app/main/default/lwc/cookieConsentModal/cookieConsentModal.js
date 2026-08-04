import { LightningElement, track, wire, api } from 'lwc';
import revokeTrustDevice from '@salesforce/apex/MfaTrustedDeviceService.revokeTrustDevice';
import trustDeviceExist from '@salesforce/apex/MfaTrustedDeviceService.trustDeviceExist';
import { refreshApex } from '@salesforce/apex';

export default class CookieConsentModal extends LightningElement {
    functionalCookies = false;
    isRevokeRequested = false;
    wiredConsentResult;

    @wire(trustDeviceExist)
    wiredTrustDeviceExist(result) {
        this.wiredConsentResult = result;
        const { data, error } = result;
        if (data !== undefined) {
            this.functionalCookies = data;
        } else if (error) {
            console.error('Error checking trusted device existence:', error);
        }
    }

    @api
    refreshData() {
        if (this.wiredConsentResult) {
            refreshApex(this.wiredConsentResult)
        }
       
    }

    connectedCallback() {
        this.refreshData();
    }

    handleToggleChange(event) {
        this.functionalCookies = event.target.checked;
        this.isRevokeRequested = !this.functionalCookies;
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    get isRevokeButtonDisabled() {
        return !this.functionalCookies;
    }

    handleSave() {
        if (!this.functionalCookies) {
            revokeTrustDevice() 
            .then((result) => {
                this.handleClose();
            })
            .catch(error => {
                console.error('Error revoking trusted devices:', error);
                this.handleClose();
            })
            .finally(() => {
            });
        }

    }

}