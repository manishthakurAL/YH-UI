import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Account.DateofDeath__c'
];

export default class accountAlert extends LightningElement {
    @api recordId; 
    account; 
    
    warningMessages; 

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if(data){
            this.account = data;
            if(this.account.fields.DateofDeath__c.value){
                this.warningMessages = 'This account is for someone who is deceased';
            } else{
                this.warningMessages = '';
            }
        }
    }
}