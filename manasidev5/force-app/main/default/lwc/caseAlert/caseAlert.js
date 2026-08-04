import { LightningElement, api, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';


export default class accountAlert extends LightningElement {
    @api recordId; 
   
    warningMessages = []; 

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',  
        relatedListId: 'Case_Role__r',
        fields: ['CaseRole__c.DateofDeath__c']
    })
    
    relatedRecords({ error, data }) {
        if (data && data.records && data.records.length > 0) {
            this.checkCaseRoleFields(data.records); 
        } 
    }
    
    checkCaseRoleFields(records) {
        let addWarning = false;
        this.warningMessages = [];

        if (records.length != 0) {
            records.forEach( (element) => {
                if (element.fields.DateofDeath__c.value) {
                    addWarning = true;
                }
            });
        }

        if(addWarning){
            this.warningMessages.push('This case has a linked account for someone who is deceased');
        }
    }
}