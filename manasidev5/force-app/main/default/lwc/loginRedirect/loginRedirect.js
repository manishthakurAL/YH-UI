import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class LoginRedirect extends NavigationMixin(LightningElement) {
    connectedCallback() {
        window.location.replace('/yhlogin');
        
    }
}