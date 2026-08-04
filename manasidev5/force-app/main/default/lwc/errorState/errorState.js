import { LightningElement, api } from 'lwc';
import LightningAlert from 'lightning/alert';

export default class ErrorState extends LightningElement {
    @api message;
    async connectedCallback() {
        await LightningAlert.open({
            message: this.message,
            theme: 'error', 
            iconName: 'utility:error', // this is the icon name##
            iconPosition: 'left', // this is the position of the icon
            iconAlternativeText: 'Error', // this is the alternative text for the icon
            variant: 'error', // this is the variant of the alert
            label: 'Error!', // this is the header text
        });
    }
}