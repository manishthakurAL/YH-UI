import { LightningElement, api, wire, track } from 'lwc';
import getVettingSupportInfoRecords from '@salesforce/apex/VettingInfoDataTable.getVettingSupportInfo';
import newModal from 'c/createVettingSupportInfoModal';
import { refreshApex } from '@salesforce/apex';
import{ShowToastEvent} from 'lightning/platformShowToastEvent';



export default class VettingInfoTable extends LightningElement {
    @api recordId;
    @api records= [];
    @api columns = [ { label: 'Vetting Reference Number', fieldName: 'link', 
    type:'url',
    typeAttributes: {
        label: {
            fieldName: 'Name'
        },
        target: '_blank'
    }},
                      { label: 'Landlord Name', fieldName: 'landlordName'},
                      { label: 'Type of Landlord', fieldName: 'typeOfLandlord'},
                      { label: 'Landlord Phone', fieldName: 'landlordPhone', type: 'Phone'},
                      { label: 'Landlord Email', fieldName: 'landlordEmail', type: 'Email'}
                    ];;
    @api error;
    wireResults;
 
    @wire(getVettingSupportInfoRecords, { recordId: '$recordId' })
    vettinsSupportInfos(result) {
        if (result) {
            this.wireResults = result;
            this.records = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.records = undefined;
        }
    }

    handleClick() {
        newModal.open({
            size: 'large',
            description: 'Create new Vetting Support Info record',
            recordId: this.recordId
        }).then((result) => {
            if(result == 'success'){
                //this.refreshVettingSupportInfoTable();
                refreshApex(this.wireResults)
                .then(()=> {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record created successfully',
                            variant: 'success'
                        })
                    );
                })
                .catch((error) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Refreshing Data',
                            message: error,
                            variant: 'error'
                        })
                    );
                });
            }
        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        
    }
}