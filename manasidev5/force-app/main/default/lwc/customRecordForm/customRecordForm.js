import { LightningElement, api } from 'lwc';
import getFormDetails from "@salesforce/apex/CustomFormController.getFormDetails";

export default class CustomRecordForm extends LightningElement {
    @api formConfigs;
    @api error;
    @api recordId;
    @api customMetaDataName;
    

    connectedCallback(){
        this.getFormDetails();
    }

    getFormDetails() {
        getFormDetails({
            parentRecordId : this.recordId,
            metadataName : this.customMetaDataName
            }).then(result => {
                if (result) {
                    this.formConfigs = result;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }
    handleSectionToggle(event){
        
    }
}