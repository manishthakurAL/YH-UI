import { api, track, wire, LightningElement } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { refreshApex } from "@salesforce/apex";
import getMutualExchange from '@salesforce/apex/MutualExchangeSwapController.getMutualExchange';
import saveNewMapping from '@salesforce/apex/MutualExchangeSwapController.saveNewMapping';
export default class MutualExchangeSwap extends LightningElement {
    @api recordId;
    @track currentProperties = [];
    @track exchangedProperties = [];
    _GetMutualExchangeWire;

    @wire(getMutualExchange, { recordId: '$recordId' })
    GetMutualExchangeWire(value) {
        this._GetMutualExchangeWire = value
        const { error, data } = value
        if (data) {
            this.extractCurrentProperties(data);
            this.extractExchangedProperties(data);
        } else if (error) {
            console.error(JSON.stringify(error));
        }
    }

    extractCurrentProperties(exchanges) {
        this.currentProperties = exchanges.map( (ex, index) => {
            return {
                'Id': ex.Id,
                'title': `${ex.PropertyType__c} Property`,
                'customer': ex.MutualExchangeApplicants__r.map(c => c.RelatedContact__r.Name).join(', '),
                'subtitle': ex.InternalPropertyAddress__c,
                'sequence': index,
                'isSelected': true,
                'draggable': false,
                'type' : ex.PropertyType__c,
                'swapNumber' : ex.ExchangeSwapNumber__c
            };
        });
    }

    extractExchangedProperties(exchanges) {
        this.exchangedProperties = exchanges.map( (ex, index) => {
            let ret = ex;
            if (ex.ExchangeSwapNumber__c) {
                ret = exchanges.find(f => f.Id === ex.ExchangeSwapNumber__c)
            } 
            return {
                'Id': ret.Id,
                'title': `${ret.PropertyType__c} Property`,
                'customer': ret.MutualExchangeApplicants__r.map(c => c.RelatedContact__r.Name).join(', '),
                'subtitle': ret.InternalPropertyAddress__c,
                'sequence': index,
                'draggable': true,
                'type' : ret.PropertyType__c,
                'swapNumber' : ret.ExchangeSwapNumber__c,
                'isSelected': (ret.ExchangeSwapNumber__c)? true:false,
                'isError': false
            }
        });
    }


    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleDrop(e) {
        let newMEX = this.template.querySelector('c-drop-zone[data-id="mex-dropzone"]').reOrderedOptions();
        this.currentProperties.forEach( (curr, index) => {
            curr.swapNumber = newMEX[index].Id
            newMEX[index].isSelected = (curr.swapNumber && (curr.Id !== newMEX[index].Id)) 
            newMEX[index].isError = ((curr.type === 'External' && newMEX[index].type === 'External') ||
                             (curr.Id === newMEX[index].Id));                   
        });
        this.currentProperties = [...this.currentProperties]
        this.exchangedProperties = [...newMEX]
    }


    handleSave(e) {
        if(!this.validate()) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "There is a mismatch with the property swaps, please review.",
                    variant: "error",
                }),
            );
            return;
        }
        let newMEX = this.template.querySelector('c-drop-zone[data-id="mex-dropzone"]').reOrderedOptions();
        let updateMexList = this.swapCurrentProperty(newMEX);
        
        saveNewMapping({
            data: JSON.stringify(updateMexList),
        }).then(()=>{
            refreshApex(this._GetMutualExchangeWire);
            this.handleClose();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Mutual Exchange updated!",
                    variant: "success",
                }),
            );
        }).catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Mutual Exchange failed! " + JSON.stringify(error.body.message),
                    variant: "error",
                }),
            );
        });    
    }

    validate() {
        let newMEX = this.template.querySelector('c-drop-zone[data-id="mex-dropzone"]').reOrderedOptions();
        let isValid = true;
        newMEX.forEach( (item, index) => {
            if ( !this.currentProperties[index].swapNumber) {
                isValid = false;
            }
        });
        return isValid;
    }

    swapCurrentProperty(newMEX) {
        
        return this.currentProperties.map( (curr, index) => {
            let ret = {
                sobjectType: "YH_Mutual_Exchange__c",
                Id: curr.Id,
                ExchangeSwapNumber__c: curr.ExchangeSwapNumber__c,
                ExchangeAddress__c: curr.ExchangeAddress__c,
            };
            if (curr.Id === newMEX[index].Id) {
                ret.ExchangeSwapNumber__c = null; 
                ret.ExchangeAddress__c = null;
            } else {
                ret.ExchangeSwapNumber__c = newMEX[index].Id; 
                ret.ExchangeAddress__c = newMEX[index].subtitle;
            }
            return ret;
        });
    }
}