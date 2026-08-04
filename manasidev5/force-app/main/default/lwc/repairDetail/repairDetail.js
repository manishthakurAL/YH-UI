import { LightningElement, api, wire } from 'lwc';

export default class RepairDetail extends LightningElement {
    @api repairinitialdata;
    
    handleClick() {
        this.dispatchEvent(new CustomEvent('handledetails',{
            detail : this.repairinitialdata
        }));
    }

}