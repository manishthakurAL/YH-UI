import { LightningElement, wire } from 'lwc';
import getCustomerPortalURL from '@salesforce/apex/CustomPortalThemeController.getCustomerPortalURL';
import * as labels from 'c/labelService';

export default class TileCards extends LightningElement {
    customerPortalUrl;
    label = labels;

    @wire(getCustomerPortalURL)
    wiredCustomerPortalUrl({data, error}){
        if (data){
            this.customerPortalUrl = data;
        }else if (error) {
            console.error('Error getting Customer Portal URL:', error);
        }
    }

    get repairUrl(){return this.customerPortalUrl ? `${this.customerPortalUrl}report-a-repair` : '#';}
    get rentUrl(){return this.customerPortalUrl ? `${this.customerPortalUrl}rent` : '#';}
    get myDetailsUrl(){return this.customerPortalUrl ? `${this.customerPortalUrl}comm-my-account` : '#';}
    get submitCaseUrl(){return this.customerPortalUrl ? `${this.customerPortalUrl}case-management` : '#';}
}