import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getCases from '@salesforce/apex/RelatedListController.getCases';

export default class RelatedList extends LightningElement {
    @api recordId; 
    @api recordTypes;
    @api relatedListName;

    _columns;
    _data;

    constructor() {
        super();
        this._columns = new Array();
        this._data = new Array();
    }

    connectedCallback() {
        this.getCases();
    }


    /**
    * @description Method to fetch the purchase request lines
    **/
    getCases() {
        getCases({
            recordTypes : this.recordTypes,
            accountId : this.recordId
        }).then(result => {
            if (result) {
                if (result.hasOwnProperty('columns')) {
                    this._columns = result['columns'];
                }
                if (result.hasOwnProperty('data')) {
                    let data = result['data'];
                    data.forEach(item => {
                        item.caseUrl = '/'+item.Id;
                        item.recordType = item.RecordType.Name;
                        item.ownerName = item.Owner.Name;
                    });
                    this._data = data;
                }
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    "message" : error,
                    "variant" : 'error'
                })
            );
            this.error = error;
        });
    }

    get numberOfCases() {
        return this._data.length;
    }
}