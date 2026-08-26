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
    
        get complaintUrl(){return this.customerPortalUrl ? `${this.customerPortalUrl}raise-complaint` : '#';}
        get ASBUrl(){return this.customerPortalUrl ? `${this.customerPortalUrl}report-issue-with-neighbour` : '#';}
        get endTenancyUrl(){return this.customerPortalUrl ? `${this.customerPortalUrl}ending-my-tenancy` : '#';}
        get rentUrl(){return this.customerPortalUrl ? `${this.customerPortalUrl}rent` : '#';}
        get askQuestionUrl(){return this.customerPortalUrl ? `${this.customerPortalUrl}ask-a-question` : '#';}
}