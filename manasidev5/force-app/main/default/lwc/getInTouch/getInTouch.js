import { LightningElement } from 'lwc';
import CP_GetInTouch from '@salesforce/label/c.CP_GetInTouch';

export default class getInTouch extends LightningElement {
    label = {
        getInTouch: CP_GetInTouch
    };
}