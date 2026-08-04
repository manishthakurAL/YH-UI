import { LightningElement, api } from 'lwc';

export default class EmptyState extends LightningElement {
    @api title;
    @api message;
    @api iconName = 'standard:account';
}