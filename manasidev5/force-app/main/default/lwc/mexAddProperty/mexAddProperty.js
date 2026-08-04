import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import MUTUAL_EXCHANGE_OBJECT from '@salesforce/schema/YH_Mutual_Exchange__c';
import MUTUAL_EXCHANGE_APPLICANT_OBJECT from '@salesforce/schema/MutualExchangeApplicant__c';
import PROPERTY_TYPE_FIELD from '@salesforce/schema/YH_Mutual_Exchange__c.PropertyType__c';
import TENANT_TYPE_FIELD from '@salesforce/schema/MutualExchangeApplicant__c.TenantType__c';
import getPropertyMembers from '@salesforce/apex/MutualExchangeController.getPropertyMembers';

export default class MexAddProperty extends LightningElement {

    @track _record = {}
    @track _oldRecord = {}
    @track applicants = [{id:1, disableDelete: true}]
    @api disableAction = false;
    @track _filterPropertyIds = [];
    propertyMembers = []
    columns = [
        { label: 'Name', fieldName: 'name', type: 'text', hideDefaultActions: true, },
        { label: 'type', fieldName: 'type', type: 'text', hideDefaultActions: true, },
        { label: 'Email', fieldName: 'email', type: 'email', hideDefaultActions: true, },
        { label: 'Phone', fieldName: 'phone', type: 'phone', hideDefaultActions: true, },
    ];

    @wire(getObjectInfo, { objectApiName: MUTUAL_EXCHANGE_OBJECT })
    mutualExchangeObjectInfo;
    @wire(getObjectInfo, { objectApiName: MUTUAL_EXCHANGE_APPLICANT_OBJECT })
    mutualExchangeApplicantObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$mutualExchangeObjectInfo.data.defaultRecordTypeId', fieldApiName: PROPERTY_TYPE_FIELD })
    propertyTypePicklistValue;

    @wire(getPicklistValues, { recordTypeId: '$mutualExchangeApplicantObjectInfo.data.defaultRecordTypeId', fieldApiName: TENANT_TYPE_FIELD })
    tenantTypePicklistValue;

    @wire(getPropertyMembers, { propertyId: '$_record.propertyId'})
    wiredGetPropertyMembers({ error, data }) {
        if (data) {
            this.propertyMembers = data.map(value => {
                return {
                    id: value.Id,
                    name:value.Contact__r.Name,
                    type:value.Type__c,
                    email:value.Contact__r.Email,
                    phone:value.Contact__r.Phone?value.Contact__r.Phone:value.Contact__r.MobilePhone,
                    agreementType:value.Tenancy__r.YH_AgreementType__c,
                }
            });
            if (data.length > 0) {
                this.applicants = data.map(value => {
                    return {
                        id: value.Id,
                        applicantId:value.Contact__c,
                        applicantName: value.Contact__r.Name,
                        applicantEmail: value.Contact__r.Email,
                        applicantPhone:value.Contact__r.Phone?value.Contact__r.Phone:value.Contact__r.MobilePhone,
                        applicantInfo: value.Contact__r.Email + ' • ' + value.Contact__r.MobilePhone,
                        tenantType : value.Type__c,
                    }
                });
            } else {
                this.applicants = [{id:1, disableDelete: true}]
            }
        }
    }

    handleChange(event) {
        var value;
        if(event.target.type === 'checkbox' || event.target.type === 'checkbox-button' || event.target.type === 'toggle'){
            value = event.target.checked;
        }else{
            value = event.target.value;
        }
        this._oldRecord = {...this._record}
        this._record = {
            ...this._record,
            [event.target.dataset.name]: value,
        };
        this.refreshUI();
    }

    refreshUI() {
        if (this._record.propertyType !== this._oldRecord.propertyType) {
            this.propertyMembers = [];
            this._record = {
                ...this._record,
                'propertyId': null,
            };
        }
    }

    handlePropertyChange(event) {
        this._filterPropertyIds.push(event.detail.id + '');
        this._record = {
            ...this._record,
            'propertyId': event.detail.id + '',
            'propertyName': event.detail.title,
            'propertyStreet': event.detail.data?.Address__Street__s,
            'propertyCity': event.detail.data?.Address__City__s,
            'propertyPostalCode': event.detail.data?.Address__PostalCode__s,
            'propertyCountry': event.detail.data?.Address__CountryCode__s,
        };
    }

    handleTenantTypeChange(event) {
        this.applicants.forEach(app => {
            if (app.id === parseInt(event.target.dataset.id)) {
                app.tenantType = event.target.value;
            } 
        })
    }

    handleAddressChange(event) {
        this._record = {
            ...this._record,
            'propertyStreet': event.target.street,
            'propertyCity': event.target.city,
            'propertyPostalCode': event.target.postalCode,
            'propertyCountry': event.target.country,
        }
    }

    handleContactChange(event) {
        this.applicants.forEach(app => {
            if (app.id === parseInt(event.target.dataset.id)) {
                app.applicantId = event.detail.id;
                app.applicantName = event.detail.title;
                app.applicantEmail = event.detail.data?.Email;
                app.applicantPhone = event.detail.data?.MobilePhone;
            } 
        })
    }

    handleApplicantAdd(event) {
        this.applicants.push({
            id: this.applicants.length + 1
        });
    }

    handleApplicantDelete(event) {
        this.applicants.splice(this.applicants.findIndex((app) => {
            return app.id === parseInt(event.target.dataset.id);
        }), 1);
    }

    get isInternal() {
        return this._record.propertyType === 'Internal';
    }

    get isExternal() {
        return this._record.propertyType === 'External';
    }

    @api getExchangePropertyInfo() {
        return {
            property : {...this._record},
            applicants : [...this.applicants],
            propertyMembers : [...this.propertyMembers],
        };
    }

    @api reset() {
        this._record = this._oldRecord = {};
        this.propertyMembers = [];
        this.applicants = [{id:1, disableDelete: true},]
    }

    @api checkValidity() {
        let isValid = true;
        this.template.querySelectorAll('.validate').forEach( inputField => {
            try{
                if (!inputField.checkValidity()) {
                    isValid = false;
                    inputField.reportValidity();
                }
            }catch(e){
                console.log('>>> error @ MexAddProperty.checkValidity ' + JSON.stringify(e))
            }
         });
        return isValid;
    }

    @api removeProperty(propertyId) {
        this._filterPropertyIds = this._filterPropertyIds.filter(item => item !== propertyId);
    }


}