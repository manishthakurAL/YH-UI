import { LightningElement, api, track } from 'lwc';
import fetchRecords from '@salesforce/apex/RecordLookupController.fetchRecords';
import fetchRecentRecords from '@salesforce/apex/RecordLookupController.fetchRecentRecords';
const DELAY = 500;

export default class RecordLookup extends LightningElement {
    @api helpText = "custom search lookup";
    @api label = "Search Records";
    @api required;
    @api selectedIconName = "standard:account";
    @api objectLabel;
    @api searchBySOSL = false;
    @api objectApiName;
    @api fieldApiName;
    @api otherFieldApiName;
    @api searchFieldApiName;
    @api searchString = "";
    @api selectedRecord;
    @track selectedRecords = [];
    @api enableMultiSelection;
    @api sortByField;
    @api hideLabel;
    @api placeholder;
    @track _filterIds = []; 
    recordsList = [];

    @api
    set filterIds(value) {
        this._filterIds = [...value]
        console.log('>>>> filters ' + JSON.stringify(this._filterIds))
    }get filterIds() {
        return this._filterIds;
    }

    preventClosingOfSerachPanel = false;

    get methodInput() {
        return {
            objectApiName: this.objectApiName,
            fieldApiName: this.fieldApiName,
            otherFieldApiName: this.otherFieldApiName,
            searchString: this.searchString,
            searchFieldApiName: this.searchFieldApiName,
            selectedRecordId: this.selectedRecord?.id,
            sortByField: this.sortByField,
            enableSOSL: this.searchBySOSL
        };
    }

    get showRecentRecords() {
        if (!this.recordsList) {
            return false;
        }
        return this.recordsList.length > 0;
    }

    connectedCallback() {
        if (this.selectedRecord && this.selectedRecord.id) {
            this.fetchSobjectRecords(true);
        }
        if (this.hideLabel) {
            this.helpText = null;
        }
    }

    fetchSobjectRecords(loadEvent) {
        if (!this.searchString || this.searchString.length < 2) {
            fetchRecentRecords({
                inputWrapper: this.methodInput
            }).then(result => {
                if (result) {
                    let searchResult = JSON.parse(JSON.stringify(result));
                    this.recordsList = searchResult.filter(item => !this._filterIds.some(anId => anId === item.id))
                } else {
                    this.recordsList = [];
                }
            }).catch(error => {
                console.log(error);
            })
        } else {
            fetchRecords({
                inputWrapper: this.methodInput
            }).then(result => {
                if (loadEvent && result) {
                    this.selectedRecord.title = result[0].title;
                    this.selectedRecord.subtitle = result[0].subtitle;
                    this.selectedRecord.id = result[0].id;
                } else if (result) {
                    let searchResult = JSON.parse(JSON.stringify(result));
                    this.recordsList = searchResult.filter(item => !this._filterIds.some(anId => anId === item.id))
                } else {
                    this.recordsList = [];
                }
            }).catch(error => {
                console.log(error);
            })
        }
        
    }

    get showSearchInput() {
        return this.enableMultiSelection || !this.selectedRecord;
    }

    get showSingleSelection() {
        return !this.enableMultiSelection && this.selectedRecord;
    }

    get showMutliSelections() {
        return this.enableMultiSelection && this.selectedRecords?.length > 0;
    }

    get variant() {
        return this.hideLabel? 'label-hidden': 'standard';
    }

    @api checkValidity() {
        var input = this.template.querySelector(
            'lightning-input'
        );
        let isValid = true
        try{
            if (!input.checkValidity()) {
                input.reportValidity();
                isValid = false;
            }
        }catch(e){
            console.log('>>> error ' + JSON.stringify(e))
        }
        return isValid;
    }

    @api reportValidity() {

    }

    handleChange(event) {
        this.searchString = event.target.value;
        this.fetchSobjectRecords(false);
    }

    handleBlur() {
        this.recordsList = [];
        this.preventClosingOfSerachPanel = false;
    }

    handleDivClick() {
        this.preventClosingOfSerachPanel = true;
    }

    handleCommit() {
        this.selectedRecord = null;
    }

    handleSelect(event) {
        let recordFound = this.recordsList.find(record => record.record.Id === event.currentTarget.dataset.id)
       
        if (this.enableMultiSelection) {
            this.selectedRecords = [...this.selectedRecords, {
                type: 'avatar',
                label: event.currentTarget.dataset.title,
                name: event.currentTarget.dataset.id,
                fallbackIconName: this.selectedIconName,
                variant: 'circle',
                alternativeText: this.selectedIconName,
                id: event.currentTarget.dataset.id,
                title: event.currentTarget.dataset.title,
                subtitle: event.currentTarget.dataset.subtitle,
            }];
        } else {
            this.selectedRecord = {
                title: event.currentTarget.dataset.title,
                subtitle: event.currentTarget.dataset.subtitle,
                id: event.currentTarget.dataset.id,
            };
        }    
        this.recordsList = [];
        let data = {
            id: event.currentTarget.dataset.id,
            title: event.currentTarget.dataset.title,
            subtitle: event.currentTarget.dataset.subtitle,
            data: recordFound.record,
        };
        
        const selectedEvent = new CustomEvent('valueselected', {
            detail: data
        });
        this.dispatchEvent(selectedEvent);
        this.searchString = '';
        this.template.querySelector('lightning-input').value = '';
    }

    handleSelectionRemove(event) {
        let recordFound = this.recordsList.find(record => record.record.Id === event.currentTarget.dataset.id)
        const name = event.detail.item.name;
        const index = event.detail.index;
        this.selectedRecords.splice(index, 1);
        let data = {
            index: index,
            data: recordFound,
        };
        
        const removeEvent = new CustomEvent('valueremoved', {
            detail: data
        });
        this.dispatchEvent(removeEvent);
    }

    handleFocus(event) {
        this.searchString = event.target.value;
        this.fetchSobjectRecords(false);  
    }
    
    handleInputBlur(event) {
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            if (!this.preventClosingOfSerachPanel) {
                this.recordsList = [];
            }
            this.preventClosingOfSerachPanel = false;
        }, DELAY);
    }

}