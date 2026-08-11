import { LightningElement } from 'lwc';

export default class YhEmergencyRepair extends LightningElement {
    isExpanded = false;

    toggleExpanded() {
        this.isExpanded = !this.isExpanded;
    }
}
