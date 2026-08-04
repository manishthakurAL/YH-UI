import { LightningElement, api } from 'lwc';

export default class RepairAccountItem extends LightningElement {
    @api repair;
    @api repairdetails;
    @api propertyaddress;
    @api showadditionalfields;
    
    handleUndo(){
        this.dispatchEvent(new CustomEvent('undo'));
    }

}