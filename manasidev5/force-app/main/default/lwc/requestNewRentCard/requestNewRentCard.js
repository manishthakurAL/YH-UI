import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { RECORD_TYPE_NAMES, ENQUIRY_TYPE, CASE_TYPE } from 'c/caseConstants';

export default class RequestNewRentCard extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference)
        currentPageReference;

    get isActive() { 
        return this.currentPageReference.state.c__isActive === 'true';
    }

    get customerName() {
        return this.currentPageReference.state.c__customerName;
    }

    get propertyAddress() {
        return this.currentPageReference.state.c__pAddress;
    }
    
    get propertyType() { 
        return this.currentPageReference.state.c__propertyType;
    }

    get tenancyId() {
        return this.currentPageReference.state.c__tenancyId;
    }

    get tenancyNumber() { 
        const value = this.currentPageReference?.state?.c__tenancyNumber;
        return value != null ? String(value) : '';
    }

    get flowName() {
        return 'SF_Community_Create_Web_to_Case';
    }

    get inputVariables() { 
        return [
            { name: 'tenancyId', type: 'String', value: this.tenancyId},
            { name: 'tenancyNumber', type: 'String', value: this.tenancyNumber },
            { name: 'caseType', type: 'String', value: CASE_TYPE.CUSTOMER_EXPERIENCE_CENTER },
            { name: 'enquiryType', type: 'String', value: ENQUIRY_TYPE.NEW_RENT_CARD },
            { name: 'recordTypeDeveloperName', type: 'String', value: RECORD_TYPE_NAMES.GENERAL_ENQUIRY }
        ];
    }

    handleStatusChange(event) {
        const status = event.detail.status;
        if (status === 'FINISHED' || status === 'CANCELLED') {
            const pageReference = {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Rent__c' 
                },
            };
            this[NavigationMixin.Navigate](pageReference);
        }
    }

    handleAllAccounts() {
        const pageReference = {
            type: 'comm__namedPage',
            attributes: {
                name: 'Rent__c' 
            },
        };
        this[NavigationMixin.Navigate](pageReference);
    }
}