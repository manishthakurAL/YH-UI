import { api, track, LightningElement } from 'lwc';

export default class DropZone extends LightningElement {
    @api title;
    @track _options = [];
    dragSource;
    dropDestination;

    @api set options(value) {
        this._options = JSON.parse(JSON.stringify(value));
        this.sortOptions();
    } get options() {
        return this._options;
    }

    @api
    reOrderedOptions() {
        return this._options;
    }

    get optsize() {
        return this._options.length;
    }

    handleDragStart(event) {
        this.dragSource = JSON.parse(JSON.stringify(event.detail));
    }

    handleDrop(event) {
        this.dropDestination = JSON.parse(JSON.stringify(event.detail));
        this.reorder();
        this.dispatchEvent(new CustomEvent('itemdrop', {}));
    }

    sortOptions() {
        this._options.sort(function (a, b) {
            return a.sequence - b.sequence;
        });
    }

    resetSequence() {
        let seq = 1;
        let oldOptions = this._options;
        oldOptions.forEach(element => {
            element.sequence = seq++;
        });
        this._options = [...oldOptions];
    }

    reorder() {        
        let oldOptions = [...this._options];
        oldOptions.forEach(element => {
            if (element.Id === this.dragSource.Id) {
                element.sequence = parseInt(this.dropDestination.sequence);
            }
            if (element.Id === this.dropDestination.Id) {
                element.sequence = parseInt(this.dragSource.sequence);
            }
        });
        
        this._options = [...oldOptions];
        this.sortOptions();
    }

    handleRemoveItem(event) {
        let removeId = event.detail;
        let index = this._options.findIndex(option => option.Id === removeId);
        let oldOptions = this._options;
        oldOptions.splice(index, 1);
        this._options = [...oldOptions];
        this.resetSequence();
    }
}