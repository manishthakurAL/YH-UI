import { api, LightningElement } from 'lwc';

export default class DragAndDropItem extends LightningElement {
    @api itemDraggable;
    @api itemId;
    @api itemTitle;
    @api itemSubtitle;
    @api itemSequence;
    @api itemSelected;
    @api isError;
    @api customerNames;


    addCSS(className) {
        this.template.querySelector('[data-id="mainDiv"]').classList.add(className);
    }

    removeCSS(className) {
        this.template.querySelector('[data-id="mainDiv"]').classList.remove(className);
    }

    get isDraggable() {
        return this.itemDraggable === true;
    }

    get styleClass() {
        if (!this.itemSelected) {
            return 'slds-box draggable-item slds-theme_default unselected slds-clearfix slds-grid slds-is-draggable slds-is-hovered';
        } 
        return (this.itemSelected && this.isError) ?
        'slds-box draggable-item slds-theme_default error slds-clearfix slds-grid slds-is-draggable slds-is-hovered':
        'slds-box draggable-item slds-theme_default match slds-clearfix slds-grid slds-is-draggable slds-is-hovered';
    }

    handleDragStart(e) { 
        this.addCSS('dragged-item');
        this.dispatchEvent(new CustomEvent('startdrag', {
            detail: {
                'Id': this.itemId,
                'sequence': this.itemSequence
            }
        }));
    }

    handleDragOver(event) {
        event.preventDefault();
        this.addCSS('over');
    }

    handleDrop(event) {
        event.preventDefault();
        event.stopPropagation();
        this.removeCSS('over');
        this.removeCSS('dragged-item');
        this.dispatchEvent(new CustomEvent('itemdrop', {
            detail: {
                'Id': this.itemId,
                'sequence': this.itemSequence
            }
        }));
    }

    handleDragEnter() {
        this.addCSS('over');
    }

    handleDragLeave() {
        this.removeCSS('over');
        this.removeCSS('dragged-item');
    }

    handleDragEnd() {
        this.removeCSS('over');
        this.removeCSS('dragged-item');
    }

    handleRemoveClick() {
        this.dispatchEvent(new CustomEvent('removeitem', {
            detail: this.itemId
        }));
    }


}