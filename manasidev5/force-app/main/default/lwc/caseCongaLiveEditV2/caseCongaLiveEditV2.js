import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import getCongaLetters from '@salesforce/apex/CongaLiveEditCtrlV2.getCongaLetters';
import getCongaTemplateByKey from '@salesforce/apex/CongaLiveEditCtrlV2.getCongaTemplateByKey';
import getLetterDraftContent from '@salesforce/apex/CongaLiveEditCtrlV2.getLetterDraftContent';
import saveLetterContent from '@salesforce/apex/CongaLiveEditCtrlV2.saveLetterContent';
import saveLetterDraftContent from '@salesforce/apex/CongaLiveEditCtrlV2.saveLetterDraftContent';
import getCongaUrl from '@salesforce/apex/CongaLiveEditCtrlV2.getCongaUrl';
export default class CaseCongaLiveEditV2 extends NavigationMixin(LightningElement) {
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
    _wiregetCongaLetters;
    _wireGetLetterContentDraft;
    _isLoading = true;
    _draftContentAvailable = false;
    

    connectedCallback() {
        this.refreshCongaSettings(this.recordId)
    }    

    refreshCongaSettings(recordId) {
        getCongaLetters({ recordId : recordId })
        .then(result => {
            if (result) {
                console.log('Conga Settings: ' + JSON.stringify(result));
                if (result.result) {
                    this._letterTemplates = {...result.result};
                } 
            } 
            this._isLoading = false;
        })
        .catch(error => {
            this._error = error;
            this._isLoading = false;
        });
    }

    @wire(getLetterDraftContent, {recordId: '$recordId', templateKey: '$_selectedCongaTemplateKey'})
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
            label : template.letterTitle,
            value : template.templateKey, 
            urlParamSettingsId : template.urlParamSettingsId
        }));
    }

    handleSaveAndSend(event) {
        this._isLoading = true;
        let actiontype = event.target.name; 
        saveLetterContent({
            recordId : this.recordId, 
            templateKey: this._selectedCongaTemplateKey,
            letterContent : this.letterContent
        }).then( () => {
            return getCongaUrl({
                recordId : this.recordId,
                urlParamSettingsId : this._selectedCongaSettingId, 
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
        this._selectedCongaSettingId = this._templateOptions.find( opt => opt.value === event.detail.value).urlParamSettingsId
        this._draftContentAvailable = false;
        this._originalTemplateContent = undefined;
        this._editedTemplateContent = undefined;
        this._selectedCongaTemplateKey = event.detail.value;
    }

    handleSaveAsDraft() {
        this._isLoading = true;
        saveLetterDraftContent({
            recordId : this.recordId,
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
                template.templateKey === this._selectedCongaTemplateKey);
            return selectedCongaSettings?.isLiveEditable;
        }
        return false;
    }

    get eSignEnabled() {
        if (this._selectedCategory && this._selectedCongaTemplateKey && this._letterTemplates) {        
            let selectedCongaSettings  = this._letterTemplates[this._selectedCategory]?.find( template => 
                template.templateKey === this._selectedCongaTemplateKey);
            return selectedCongaSettings?.isESigningEnabled;
        }
        return false;
    }

    get inPersonSigningEnabled() {
        if (this._selectedCategory && this._selectedCongaTemplateKey && this._letterTemplates) {        
            let selectedCongaSettings  = this._letterTemplates[this._selectedCategory]?.find( template => 
                template.templateKey === this._selectedCongaTemplateKey);
            return selectedCongaSettings?.isInPersonSigningEnabled;
        }
        return false;
    }

}