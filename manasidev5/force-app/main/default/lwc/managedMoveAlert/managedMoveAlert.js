import { LightningElement, api, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';


export default class managedMoveAlert extends LightningElement {
    @api recordId; 
   
    warningMessages = []; 

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',  
        relatedListId: 'Managed_Moves__r',
        fields: ['ManagedMove__c.OfferStatus__c', 'ManagedMove__c.TenantRemaining__c']
    })
    relatedRecords({ error, data }) {
        if (data && data.records && data.records.length > 0) {
            this.checkManagedMoveFields(data.records); 
        } 
    }
    checkManagedMoveFields(records) {
        this.warningMessages = [];

        if (records.length != 0) {
            const managedMoveRecord = records[0];

            if (managedMoveRecord.fields.OfferStatus__c && managedMoveRecord.fields.OfferStatus__c.value === 'Accepted') {
                this.warningMessages.push('Let the customer know they need to provide notice to end the tenancy on their present property, and they will pay rent on both properties until that tenancy ends.');
            }

            if (managedMoveRecord.fields.TenantRemaining__c && managedMoveRecord.fields.TenantRemaining__c.value === 'Yes') {
                this.warningMessages.push('If it is appropriate, let the remaining tenant know that we will be in touch to change the tenancy agreement.');
            }
        }
    }
}