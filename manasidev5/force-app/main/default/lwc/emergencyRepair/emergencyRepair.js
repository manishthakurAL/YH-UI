import { LightningElement } from 'lwc';

export default class emergencyRepair extends LightningElement {
    isExpanded = false;

    toggleExpanded() {
        this.isExpanded = !this.isExpanded;
    }
}