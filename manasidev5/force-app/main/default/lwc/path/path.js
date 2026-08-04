import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { NavigationMixin } from 'lightning/navigation';
import pathStyle from '@salesforce/resourceUrl/Path';
import { loadStyle } from 'lightning/platformResourceLoader';
import fetchPathConfiguration from '@salesforce/apex/PathController.fetchPathConfiguration';
import getPathSetting from '@salesforce/apex/PathController.getPathSetting';
import { getRecord } from 'lightning/uiRecordApi';

export default class Path extends NavigationMixin(LightningElement) {
    @api recordId;
    @api fieldName;
    @api isDependantPicklist;
    @api masterFieldName;

    _fieldValue;
    _record;
    _picklistOptions;
    _pathSetting;
    _sObjectName;
    _fieldsList;
    _fieldLabel;
    _selectedValue;
    _valueOnHover;
    _recordTypeId;
    _fieldUIAPIName;
    _masterFieldValue;
    _fieldLabelsList;
    _isDataNotValidToUpdate;
    _isReadyToLoad;

    @wire(getPicklistValues,{recordTypeId: '$_recordTypeId' , fieldApiName: '$_fieldUIAPIName'})
    wiredPicklistOptions({error,data}){
        if (data && data.hasOwnProperty('values')){
            this._picklistOptions = new Array();
            data.values.forEach(validPicklistValueForRecordType => {
                let isValidValue = false;
                if (!this.isDependantPicklist || (this.isDependantPicklist && data.hasOwnProperty('controllerValues') 
                    && data.controllerValues.hasOwnProperty(this._masterFieldValue) && validPicklistValueForRecordType.validFor.some(item => item == data.controllerValues[this._masterFieldValue]))) {
                    isValidValue = true;
                }
                if (isValidValue) {
                    this._picklistOptions.push({
                        'label' : validPicklistValueForRecordType.label,
                        'name' : validPicklistValueForRecordType.value
                    });
                }
            });
        }
        this.hide();
    };

    @wire(getRecord, { recordId: '$recordId', layoutTypes: 'Full' })
    getCase({ data, error }) {
        if (data) {
            if (!this._selectedValue) {
                this._isReadyToLoad = false;
                this.fetchPathConfiguration();
            }
        } else if (error) {
        }
    }



    constructor() {
        super();
        this._selectedValue = '';
        this._valueOnHover = '';
        this._picklistOptions = new Array();
        this._isDataNotValidToUpdate = false;
        this._isReadyToLoad = false;
    }

    connectedCallback() {
        this.fetchPathConfiguration();
        loadStyle(this, pathStyle).then(() => {
        }).catch(error => {
        });
    }

    fetchPathConfiguration() {
        this._selectedValue = '';
        this._fieldValue = '';
        this._fieldsList = new Array();
        this._pathSetting = undefined;
        fetchPathConfiguration({
                recordId : this.recordId,
                fieldAPIName : this.fieldName,
                isDependantPicklist : this.isDependantPicklist,
                masterFieldName : this.masterFieldName
            }).then(result => {
                if (result.record) {
                    this._record = result.record;
                    this._fieldValue = this._record[this.fieldName];
                    if (this.isDependantPicklist && this._record.hasOwnProperty(this.masterFieldName)) {
                        this._masterFieldValue = this._record[this.masterFieldName];
                    }
                }
                if (result.sObjectName) {
                    this._sObjectName = result.sObjectName;
                }
                if (result.fieldLabels) {
                    this._fieldLabelsList = result.fieldLabels;
                    this._fieldLabel = this._fieldLabelsList.hasOwnProperty(this.fieldName.toLowerCase()) ? this._fieldLabelsList[this.fieldName.toLowerCase()] : '';
                }
                if (result.pathSetting) {
                    this._pathSetting = result.pathSetting;
                    if (this._pathSetting && this._pathSetting.hasOwnProperty('Configuration__c')) {
                        this._fieldsList = JSON.parse(this._pathSetting['Configuration__c']).columns;
                    }
                }
                this._recordTypeId = this._record.hasOwnProperty('RecordTypeId') ? this._record.RecordTypeId : (result.orgSetting ? result.orgSetting.DefaultRecordTypeId__c : '');// NULL RECORD TYPE ID FOR ALL OBJECTS
                this._fieldUIAPIName = {"fieldApiName": this.fieldName,"objectApiName":this._sObjectName};
                this._isReadyToLoad = true;
            })
            .catch(error => {
                this.hide();
                console.log(JSON.stringify(error));
        });
    }

    handleOnClick(event) {
        this.show();
        this._selectedValue = event.target.value;
        this._fieldsList = new Array();
        getPathSetting({
            sObjectName : this._sObjectName,
            fieldValue : this._selectedValue,
            masterFieldValue : this._masterFieldValue
        }).then(result => {
            if (result) {
                this._pathSetting = result;
                if (this._pathSetting && this._pathSetting.hasOwnProperty('Configuration__c')) {
                    this._fieldsList = JSON.parse(this._pathSetting['Configuration__c']).columns;
                }
            }   
            this.validate();
            this.hide();
        }).catch(error => {
            this.hide();
        });
    }

    handleMouseOver(event) {
        if (event.currentTarget.label) {
            this._valueOnHover = event.currentTarget.label;
        }
    }

    handleMouseOut(event) {
        this._valueOnHover = '';
    }
    
    handleOnComplete(event) {
        if (this._selectedValue && this._fieldValue !== this._selectedValue) {
            this.updatesObjectRecord();
        }
    }

    hide() {
        if (this.template.querySelector('lightning-spinner')) {
            this.template.querySelector('lightning-spinner').classList.add('slds-hide');
        }
    }

    show() {
        if (this.template.querySelector('lightning-spinner')) {
            this.template.querySelector('lightning-spinner').classList.remove('slds-hide');
        }
    }


    updatesObjectRecord(){
        const fields = {
            ['Id'] : this.recordId,
            [this.fieldName] : this._selectedValue
        };
        updateRecord({fields}).then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    "message" : this._fieldLabel+" has been updated successfully",
                    "variant" : 'success'
                }),
            );
            this.fetchPathConfiguration();
        }).catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    "message" : this.getErrorMessage(error),
                    "variant" : 'error'
                }),
            );
        });
    }

    getErrorMessage(error) {
        let errorMessage = '';
        let counter = 1;
        if (error && error.body && error.body.output && error.body.output.errors) {
            error.body.output.errors.forEach(recordError => {
                errorMessage += (errorMessage != '' ? '\r\n' : '')+counter+'. '+recordError.message;
                counter++;
            });
        }
        if (error && error.body && error.body.output && error.body.output.fieldErrors) {
            Object.values(error.body.output.fieldErrors).forEach(recordErrors => {
                recordErrors.forEach(recordError => {
                    errorMessage += (errorMessage != '' ? '\r\n' : '')+counter+'. '+recordError.message;
                    counter++;
                });
            });
        }
        return errorMessage;
    }

    handleSuccess(event) {
        this.validate();
        this.dispatchEvent(
            new ShowToastEvent({
                "message" : "Record has been updated successfully",
                "variant" : 'success'
            }),
        );
    }

    handleLoad(event) {
        this.validate();
    }

    validate() {
        this._isDataNotValidToUpdate = false;
        this._fieldsList.forEach(field => {
            if (field.required && this.template.querySelector('[data-fieldname='+field.fieldName+']') 
                && !this.template.querySelector('[data-fieldname='+field.fieldName+']').value) {
                this._isDataNotValidToUpdate = true;
            }
        });
    }

    get hasFieldsToUpdate() {
        return this._pathSetting !== undefined && this._fieldsList.length > 0;
    }

    get buttonLabel() {
        return 'Set '+this._fieldLabel;
    }

    get hasPicklistOptions() {
        return this._picklistOptions !== undefined && this._picklistOptions.length > 0;
    }

    get message() {
        return 'No '+this._fieldLabel+' values to display'+(this.isDependantPicklist ? ' for '+this._masterFieldValue : '')+'.';
    }
}