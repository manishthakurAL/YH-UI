import { LightningElement, api, track, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import { updateRecord, getRecord, notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import getCongaSettings from '@salesforce/apex/CongaLiveEditController.getCongaSettings';
import getCongaTemplateByKey from '@salesforce/apex/CongaLiveEditController.getCongaTemplateByKey';
import getLetterDraftContent from '@salesforce/apex/CongaLiveEditController.getLetterDraftContent';
import saveCase from '@salesforce/apex/CongaLiveEditController.saveCase';
import saveLetterDraftContent from '@salesforce/apex/CongaLiveEditController.saveLetterDraftContent';
import getCongaUrl from '@salesforce/apex/CongaLiveEditController.getCongaUrl';
import LETTER_CONTENT_FIELD from "@salesforce/schema/Case.LetterContent__c";
import ID_FIELD from "@salesforce/schema/Case.Id";
import CASE_CONGA_SETTING_FIELD from "@salesforce/schema/Case.CaseCongaSetting__c";
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import LAST_MODIFIED_DATE from '@salesforce/schema/Case.LastModifiedDate';
import OWNER_ID from '@salesforce/schema/Case.OwnerId';
import { RefreshEvent } from "lightning/refresh";
export default class CaseCongaLiveEdit extends NavigationMixin(LightningElement) {
    @api recordId; 
    @track _templateOptions = [];
    _congaSettingsList;
    _letterTemplates;
    _selectedCongaTemplateKey;
    _selectedCongaSettingId;
    _caseRecord;
    _error;
    _savedTemplateContent;
    _originalTemplateContent;
    _editedTemplateContent;
    _initFirst = true;
    _lastModifiedDate;
    _wireGetCongaSettings;
    _wireGetLetterContentDraft;
    _isLoading = true;
    _draftContentAvailable = false;
    

    connectedCallback() {
        this.refreshCongaSettings(this.recordId)
    }    

    @wire(getRecord, { recordId: '$recordId', fields:  [CASE_NUMBER, OWNER_ID, LAST_MODIFIED_DATE] })
    wiredRecord({ error, data }) {
        if (data) {
            let modifiedDate = data.lastModifiedDate;
            if (modifiedDate != this._lastModifiedDate) {
                this._error = undefined;
                this._caseRecord = undefined;
                this._letterTemplates = undefined;
                this._selectedCongaTemplateKey = undefined;
                this._templateOptions = [];
                this._originalTemplateContent = undefined;
                this._editedTemplateContent = undefined;
                this._initFirst = true;                
                if (this._lastModifiedDate) {
                    this.refreshCongaSettings(this.recordId)
                }
                this._lastModifiedDate = data.lastModifiedDate;             
            }
        }
        
    }

    refreshCongaSettings(caseId) {
        getCongaSettings({ recordId : caseId })
        .then(result => {
            if (result) {
                if (result.caseRecord) {
                    this._caseRecord = result.caseRecord;
                } 
                if (result.letterTemplates) {
                    this._letterTemplates = result.letterTemplates;
                } 
            } 
            this._isLoading = false;
        })
        .catch(error => {
            this._error = error;
            this._isLoading = false;
        });
    }

    @wire(getLetterDraftContent, {caseId: '$recordId', templateKey: '$_selectedCongaTemplateKey'})
    wireGetLetterContentDraft(wireResult) {
        const { error, data } = wireResult;
        this._wireGetLetterContentDraft = wireResult;
        if (data) {
            this._draftContentAvailable = true;
            this._editedTemplateContent = data;
        } else if (error) {
            this._error = error;
        }
        this._isLoading = false;
    }

    @wire(getCongaTemplateByKey, {templateKey: '$_selectedCongaTemplateKey'})
    wireGetCongaTemplateByKey({ error, data }) {
        if (data) {
            this._originalTemplateContent = data.LetterContent__c;
        } else if (error) {
            this._error = error;
        }
    }

    get letterContent() {
        return this._draftContentAvailable ? this._editedTemplateContent : this._originalTemplateContent;
    }

    get isTemplateSelected() {
        return this._selectedCongaTemplateKey !== undefined && this._selectedCongaTemplateKey != '';
    }

    get categoryOptions() {
        let options = [];
        if (this._letterTemplates) {
            options = Object.keys(this._letterTemplates).map(
                category => ({
                    label : category,
                    value : category
                })
            );
        }
        if (options.length == 1 && this._initFirst) {
            this._initFirst = false;
            let event = { detail : { value : options[0].value , }}
            this.handleOnCategoryChange(event);
        } 
        return options;
    }

    get showCategoryOptions() {
        return (this.categoryOptions.length > 1)
    }

    handleChangeContentEdit(event) {
        let parent = this;
        this._draftContentAvailable = true;
        this._editedTemplateContent = event.target.value;
    }

    handleOnCategoryChange(event) {
        this._templateOptions = [];
        this._selectedCongaTemplateKey = undefined;
        this._selectedCategory = event.detail.value;        
        this._templateOptions = this._letterTemplates[this._selectedCategory]?.map( template => ({
            label : template.LetterType__c,
            value : template.CongaDocumentGenerationSetting__r.TemplateId__c,
            templateId : template.Id
        }));
    }

    handleSaveAndSend(event) {
        this._isLoading = true;
        let actiontype = event.target.name; 
        saveCase({
            caseId : this.recordId, 
            templateKey: this._selectedCongaTemplateKey,
            letterContent : this.letterContent
        }).then( () => {
            return getCongaUrl({
                recordId : this.recordId,
                congaSettingId : this._selectedCongaSettingId, 
                actionType : actiontype
            })
        }).then( (result) => {
                this._isLoading = false;
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: { 
                        url: result
                    }
                },true);
        }).catch((error) => {
            this._isLoading = false;
            this._error = error;
        });
    }

    handleOnLetterTypeChange(event) {
        this._isLoading = true;
        this._selectedCongaSettingId = this._templateOptions.find( opt => opt.value === event.detail.value).templateId
        this._draftContentAvailable = false;
        this._originalTemplateContent = undefined;
        this._editedTemplateContent = undefined;
        this._selectedCongaTemplateKey = event.detail.value;
    }

    handleSaveAsDraft() {
        this._isLoading = true;
        saveLetterDraftContent({
            caseId : this.recordId,
            templateKey: this._selectedCongaTemplateKey,
            letterContent: this.letterContent
        }).then((result) => {
            this._isLoading = false;
            refreshApex(this._wireGetLetterContentDraft)
        }).catch((error) => {
            this._isLoading = false;
            this._error = error;
        });
    }


    async handleCancel() {
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to discard changes?',
            variant: 'headerless',
            label: 'Confirm!',
        });
        if (result) {
            this._editedTemplateContent = this._originalTemplateContent;
        }
    }

    get disableActionButtons() {
        if (this._selectedCategory && this._selectedCongaTemplateKey) {
            return false;
        } 
        return true;
    }

    get hasLetterTemplate() {
        return this.templates?.length > 0;
    }

    get hasLetterTemplateSelected() {
        return this._selectedCongaTemplateKey !== undefined && this._selectedCongaTemplateKey != '';
    }

    get enabledLiveEditOnSelectedTemplate() {
        if (this._selectedCategory && this._selectedCongaTemplateKey && this._letterTemplates) {        
            let selectedCongaSettings  = this._letterTemplates[this._selectedCategory]?.find( template => 
                template.CongaDocumentGenerationSetting__r.TemplateId__c === this._selectedCongaTemplateKey);
            return selectedCongaSettings?.LiveEditable__c;
        }
        return false;
    }

    get eSignEnabled() {
        if (this._selectedCategory && this._selectedCongaTemplateKey && this._letterTemplates) {        
            let selectedCongaSettings  = this._letterTemplates[this._selectedCategory]?.find( template => 
                template.CongaDocumentGenerationSetting__r.TemplateId__c === this._selectedCongaTemplateKey);
            return selectedCongaSettings?.EnableESign__c;
        }
        return false;
    }

    get inPersonSigningEnabled() {
        if (this._selectedCategory && this._selectedCongaTemplateKey && this._letterTemplates) {        
            let selectedCongaSettings  = this._letterTemplates[this._selectedCategory]?.find( template => 
                template.CongaDocumentGenerationSetting__r.TemplateId__c === this._selectedCongaTemplateKey);
            return selectedCongaSettings?.EnableInPersonSigning__c;
        }
        return false;
    }

}