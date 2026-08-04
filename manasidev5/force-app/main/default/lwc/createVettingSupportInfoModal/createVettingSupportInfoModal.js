import { LightningElement, api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getVettingId from '@salesforce/apex/VettingInfoDataTable.getVettingId';
import{ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class CreateVettingSupportInfoModal extends LightningModal {
    @api recordId;
    @api vettingRecordId;
    @api disable;

    @wire(getVettingId, { applicantId: '$recordId' })
    vetting(result) {
        if (result) {
            this.vettingRecordId = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
        }
    }
    
    handleSuccess(){
        this.close('success');
    }

    handleSubmit(event) {
        event.preventDefault(); // Stop the form from submitting
        const fields = event.detail.fields;
        // Modify fields if necessary
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleError(event) {
    }
}