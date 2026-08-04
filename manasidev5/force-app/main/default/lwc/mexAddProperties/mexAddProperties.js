import { LightningElement, track, api } from 'lwc';
import saveMutualExchanges from '@salesforce/apex/MutualExchangeController.saveMutualExchanges';
import {
    FlowAttributeChangeEvent,
    FlowNavigationBackEvent,
    FlowNavigationNextEvent,
} from 'lightning/flowSupport';

export default class MexAddProperties extends LightningElement {

    @track exchangeInfos =[];
    @api noOfPropertiesInvolved = 2;
    @api recordId;
    error;
    warningMessage;
    @api ineligibileAgreementType = false;


    get hasProperty(){
        return this.exchangeInfos.length > 0;
    }

    get disableAddPropertyButton() {
        return  this.exchangeInfos.length >= this.noOfPropertiesInvolved;
    }

    handleNoOfPropertiesInvolved(event) {
        this.noOfPropertiesInvolved = parseInt(event.detail.value);
        const attributeChangeEvent = new FlowAttributeChangeEvent(
            'noOfPropertiesInvolved',
            this.noOfPropertiesInvolved
        );
    }

    handleAddProperty(event) {
        let mexPropertyCmp = this.template.querySelector('c-mex-add-property');
        let isValid = mexPropertyCmp.checkValidity();
        try {
            if (isValid) {
                let propertyAdded = {...mexPropertyCmp.getExchangePropertyInfo()};
                this.exchangeInfos.push(propertyAdded);
                this.checkAgreementTypeAndSetWarning();     
                mexPropertyCmp.reset();
            }
        }catch(e) {
            this.error = 'ERROR: ' + JSON.stringify(e);
        }
    }

    handlePropertyDelete(event) {
        this.template.querySelector('c-mex-add-property').removeProperty(event.target.dataset.id);
        this.exchangeInfos.splice(this.exchangeInfos.findIndex((prop) => {
            return prop.property.propertyId === event.target.dataset.id;
        }), 1);
        this.checkAgreementTypeAndSetWarning();     
    }

    handleSave(event) {
        if(this.exchangeInfos.length !== this.noOfPropertiesInvolved) {
            this.error = 'Add all the properties involved in the mutual exchange.';
            return;
        }
        saveMutualExchanges( {caseId : this.recordId, data: JSON.stringify(this.exchangeInfos)})
        .then(() => {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }).catch((error) => {
            this.error = error.body.message;
        })
    }

    handlePrevious(event) {
        const navigatePrevEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigatePrevEvent);
    }
    checkAgreementTypeAndSetWarning(){
        if (this.exchangeInfos.length >= this.noOfPropertiesInvolved) {
            const invalidAgreementTypes = [
                'Starter Tenancy',
                'Assured Shorthold Tenancy',
                'Market Rent',
                'Intermediate Rent',
                'Rent to Buy'
            ];
            
            let ineligibile = false;
            let invalidAgreementType = '';
        
            this.exchangeInfos.forEach(info => {
            if (info.property.propertyType === 'Internal') {
                info.propertyMembers.forEach(propertyMember => {
                    if(invalidAgreementTypes.includes(propertyMember.agreementType)){
                        ineligibile = true;
                        invalidAgreementType = propertyMember.agreementType;
                        return;
                    } 
                });
            }
            if (ineligibile) {
                return;
            }
            });

            this.handleIneligibileAgreementType(ineligibile);

            if (ineligibile) {
            this.warningMessage = 'This case will be closed as refused as you cannot create a mutual exchange when the agreement type is '+ invalidAgreementType +'. Please signpost the customer to alternative rehousing options.';
            } else {
            this.warningMessage = '';  
            }
        }
        else{
            this.warningMessage = '';  
        }
    }
    handleIneligibileAgreementType(ineligibile){
        
        this.ineligibileAgreementType = ineligibile;
        const attributeChangeEvent = new FlowAttributeChangeEvent(
            'ineligibileAgreementType',
            this.ineligibileAgreementType
        );
        this.dispatchEvent(attributeChangeEvent);
    }
}