import { LightningElement, api } from 'lwc';
import getFormDetails from "@salesforce/apex/CustomFormController.getParentDisplayConfigDetails";

export default class ShowParentDetailOnChild extends LightningElement {
    @api parentConfigs;
    @api error;
    @api recordId;
    @api customMetaDataName;
    
    connectedCallback(){
        this.getFormDetails();
    }

    getFormDetails() {
        getFormDetails({
            childRecordId : this.recordId,
            metadataName : this.customMetaDataName
            }).then(result => {
                console.log('here');

                if (result) {
                    console.log('here');
                    this.parentConfigs = result;
                    console.log('here',result);
                }
            })
            .catch(error => {
                this.error = error;
            });
    }
}